import 'dart:async';
import 'dart:developer';

import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_history_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/step/models/step_model.dart';
import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/dialogs/confirm_dialog.dart';
import 'package:aco_plus/app/core/models/app_stream.dart';
import 'package:aco_plus/app/core/services/notification_service.dart';
import 'package:aco_plus/app/modules/kanban/kanban_view_model.dart';
import 'package:aco_plus/app/modules/pedido/pedido_controller.dart';
import 'package:aco_plus/app/modules/usuario/usuario_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const stepIdAguardandoProd = 'E2chjojxDVgeHa3i248t3Xl5O';

final kanbanCtrl = StepController();

class StepController {
  static final StepController _instance = StepController._();

  StepController._();

  factory StepController() => _instance;

  final AppStream<KanbanUtils> utilsStream = AppStream<KanbanUtils>();
  KanbanUtils get utils => utilsStream.value;

  Future<void> onInit() async {
    await FirestoreClient.pedidos.fetch();
    final kanban = mountKanban();
    final calendar = _mountCalendar();
    utilsStream.add(KanbanUtils(kanban: kanban, calendar: calendar));
    onMount();
  }

  void onMount() async {
    final kanban = mountKanban();
    final calendar = _mountCalendar();
    utils.calendar = calendar;
    utils.kanban = kanban;
    utilsStream.update();
  }

  Map<StepModel, List<PedidoModel>> mountKanban() {
    final pedidos = FirestoreClient.pedidos.data.toList();
    final kanban = <StepModel, List<PedidoModel>>{};
    for (StepModel step in FirestoreClient.steps.data.toList()) {
      final pedidosStep = pedidos.where((e) => e.step.id == step.id).toList();
      pedidosStep.sort((a, b) => a.index.compareTo(b.index));
      if (step.id == stepIdAguardandoProd) {
        log('');
      }
      kanban.addAll({step: pedidosStep});
    }
    return kanban;
  }

  Future<void> onMountCalendar() async {
    await FirestoreClient.pedidos.fetch();
    utils.calendar = _mountCalendar();
    utilsStream.update();
  }

  Map<String, List<PedidoModel>> _mountCalendar() {
    final calendar = <String, List<PedidoModel>>{};
    final keys = FirestoreClient.pedidos.data
        .where((e) => e.deliveryAt != null)
        .map((e) => e.deliveryAt!)
        .toSet();
    for (DateTime key in keys) {
      calendar[DateFormat('dd/MM/yyyy').format(key)] = FirestoreClient
          .pedidos.data
          .where((e) => e.deliveryAt == key)
          .toList();
    }
    return calendar;
  }

  void updateKanban() {
    utils.kanban = mountKanban();
    utilsStream.update();
  }

  void setPedido(PedidoModel? pedido) {
    utils.pedido = pedido;
    utilsStream.update();
  }

  void onAccept(
    StepModel step,
    PedidoModel pedido,
    int index,
  ) async {
    if (!onWillAccept(pedido, step)) return;
    _onMovePedido(pedido, step, index);
    _onAddStep(pedido, step);
    utilsStream.update();
  }

  bool onWillAccept(PedidoModel pedido, StepModel step) {
    if (pedido.step.id != step.id) {
      final isStepAvailable =
          step.fromSteps.map((e) => e.id).contains(pedido.step.id);
      if (!isStepAvailable) {
        NotificationService.showNegative(
            'Operação não permitida', 'Etapa não aceita esta operação');
        return false;
      }
    }
    final isUserAvailable = step.moveRoles.contains(usuario.role) &&
        pedido.step.moveRoles.contains(usuario.role);
    if (!isUserAvailable) {
      NotificationService.showNegative('Operação não permitida',
          'Usuário não tem permissão para alterar essa etapa');
      return false;
    }
    return true;
  }

  void _onAddStep(PedidoModel pedido, StepModel step) {
     pedido.histories.add(
      PedidoHistoryModel.create(
          data: step,
          action: PedidoHistoryAction.update,
          type: PedidoHistoryType.step),
    );
    pedido.addStep(step);
    FirestoreClient.pedidos.dataStream.update();
    FirestoreClient.pedidos.update(pedido);
  }

  void _onMovePedido(PedidoModel pedido, StepModel step, int index) {
    _onAddPedidoFromStep(step.id, index,
        pedido: _onRemovePedidoFromStep(pedido.step.id, pedido.id));
    _onUpdatePedidosIndex(step.id, index);
  }

  PedidoModel _onRemovePedidoFromStep(String stepId, String pedidoId) {
    final key = utils.kanban.keys.firstWhere((e) => e.id == stepId);
    final pedido = utils.kanban[key]!.firstWhere((e) => e.id == pedidoId);
    utils.kanban[key]!.remove(pedido);
    return pedido;
  }

  void _onAddPedidoFromStep(String stepId, int index,
      {required PedidoModel pedido}) {
    final key = utils.kanban.keys.firstWhere((e) => e.id == stepId);
    utils.kanban[key]!.insert(index, pedido);
  }

  void _onUpdatePedidosIndex(String stepId, int index) {
    final key = utils.kanban.keys.firstWhere((e) => e.id == stepId);
    List<PedidoModel> pedidos = utils.kanban[key]!;
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < pedidos.length; i++) {
      pedidos[i].index = i;
      batch.update(FirestoreClient.pedidos.collection.doc(pedidos[i].id),
          {'index': pedidos[i].index});
    }
    batch.commit();
  }

  void onListenerSrollEnd(BuildContext context, Offset mouse) {
    Alignment? align = _getAlignByPosition(context, mouse);
    if (align == null && utils.timer != null) {
      utils.cancelTimer();
    } else if (align != null && utils.timer == null) {
      _setTimerByAlign(align);
    }
  }

  Alignment? _getAlignByPosition(BuildContext context, Offset mouse) {
    const gap = 200;
    final maxWidth =
        (MediaQuery.of(context).size.width + utils.scroll.offset) - gap;
    final minWidth = gap + utils.scroll.offset;
    final dx = mouse.dx + utils.scroll.offset;
    if (dx >= maxWidth) {
      return Alignment.centerRight;
    } else if (dx < minWidth) {
      return Alignment.centerLeft;
    } else {
      return null;
    }
  }

  void _setTimerByAlign(Alignment align) {
    if (align == Alignment.centerRight) {
      utils.timer = Timer.periodic(const Duration(milliseconds: 300),
          (timer) => _updateScrollSteps(utils.scroll.offset + 100));
    } else {
      utils.timer = Timer.periodic(const Duration(milliseconds: 300),
          (timer) => _updateScrollSteps(utils.scroll.offset - 100));
    }
  }

  void _updateScrollSteps(double offset) {
    utils.scroll.animateTo(offset,
        curve: Curves.ease, duration: const Duration(milliseconds: 300));
  }

  void onUndoStep(PedidoModel pedido) async {
    final step = pedido.steps[pedido.steps.length - 2].step;
    if (!await showConfirmDialog('Deseja voltar para etapa anterior?',
        'Seu pedido será movido para ${step.name}')) return;
    _onMovePedido(pedido, step, 0);
    _onAddStep(pedido, step);
    utilsStream.update();
  }
}
