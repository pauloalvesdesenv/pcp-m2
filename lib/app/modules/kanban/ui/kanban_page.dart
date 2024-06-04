import 'dart:math';

import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_step_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/step/models/step_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/tag/models/tag_model.dart';
import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/components/app_drawer.dart';
import 'package:aco_plus/app/core/components/app_scaffold.dart';
import 'package:aco_plus/app/core/components/h.dart';
import 'package:aco_plus/app/core/components/stream_out.dart';
import 'package:aco_plus/app/core/components/w.dart';
import 'package:aco_plus/app/core/extensions/date_ext.dart';
import 'package:aco_plus/app/core/services/hash_service.dart';
import 'package:aco_plus/app/core/utils/app_colors.dart';
import 'package:aco_plus/app/core/utils/app_css.dart';
import 'package:aco_plus/app/modules/base/base_controller.dart';
import 'package:flutter/material.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  @override
  void initState() {
    FirestoreClient.steps.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => baseCtrl.key.currentState!.openDrawer(),
          icon: Icon(
            Icons.menu,
            color: AppColors.white,
          ),
        ),
        title: Text('Kaban', style: AppCss.largeBold.setColor(AppColors.white)),
        backgroundColor: AppColors.primaryMain,
      ),
      body: StreamOut(
        stream: FirestoreClient.steps.dataStream.listen,
        builder: (context, steps) => StreamOut(
          stream: FirestoreClient.pedidos.dataStream.listen,
          builder: (context, pedidos) => Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/kanban_background.png'),
              fit: BoxFit.cover,
            )),
            child: Column(
              children: [
                const H(16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: steps.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, i) => const W(16),
                    itemBuilder: (_, i) => _stepWidget(
                        steps[i],
                        pedidos
                            .where((e) => steps[i].id == e.step.id)
                            .toList()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(StepModel step, List<PedidoModel> pedidos) {
    pedidos.sort((a, b) => a.index.compareTo(b.index));
    return Container(
      width: 300,
      // padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F2F4),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              step.name,
              style: AppCss.minimumBold,
            ),
          ),
          Expanded(
            child: DragTarget<PedidoModel>(
              onAcceptWithDetails: (details) {
                final pedido = FirestoreClient.pedidos.data
                    .firstWhere((e) => e.id == details.data.id);
                pedido.steps.add(PedidoStepModel(
                    id: HashService.get,
                    step: step,
                    createdAt: DateTime.now()));
                FirestoreClient.pedidos.update(pedido);
              },
              builder: (_, __, ___) => Scrollbar(
                controller: step.scrollController,
                interactive: true,
                radius: const Radius.circular(4),
                thickness: 8,
                child: ListView(
                  children: [
                    DragTarget<PedidoModel>(
                      onAcceptWithDetails: (details) =>
                          onAccept(details, step, pedidos, index: 0),
                      builder: (_, __, ___) => const H(8),
                    ),
                    ListView.separated(
                      controller: step.scrollController,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      separatorBuilder: (_, i) => DragTarget<PedidoModel>(
                        onAcceptWithDetails: (details) =>
                            onAccept(details, step, pedidos),
                        builder: (_, __, ___) => const H(8),
                      ),
                      itemCount: pedidos.length,
                      itemBuilder: (_, e) => _itemListViewWidget(pedidos, e),
                    ),
                    DragTarget<PedidoModel>(
                      onAcceptWithDetails: (details) => onAccept(
                          details, step, pedidos,
                          index: pedidos.length),
                      builder: (_, __, ___) => const H(8),
                    ),
                  ], 
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onAccept(DragTargetDetails<PedidoModel> details, StepModel step,
      List<PedidoModel> pedidos,
      {int? index}) {
    PedidoModel pedido =
        FirestoreClient.pedidos.data.firstWhere((e) => e.id == details.data.id);
    if (pedido.step.id != step.id) {
      pedido.steps.add(PedidoStepModel(
          id: HashService.get, step: step, createdAt: DateTime.now()));
      FirestoreClient.pedidos.dataStream.update();
      FirestoreClient.pedidos.update(pedido);
    }
    pedido =
        FirestoreClient.pedidos.data.firstWhere((e) => e.id == details.data.id);
    final pedidosByStep = pedidos.where((e) => e.step.id == step.id).toList();
    final i = index ?? pedidosByStep.indexOf(pedido);
    pedidosByStep.removeAt(i);
    pedidosByStep.insert(i, pedido);
    pedido.index = i;
    FirestoreClient.pedidos.dataStream.update();
  }

  LongPressDraggable<PedidoModel> _itemListViewWidget(
      List<PedidoModel> pedidos, int e) {
    return LongPressDraggable<PedidoModel>(
        onDragCompleted: () {
          // FirestoreClient.pedidos.update(
          //     pedidos[e].copyWith(step: step));
        },
        delay: const Duration(milliseconds: 100),
        data: pedidos[e],
        childWhenDragging: SizedBox(
          width: 290,
          child:
              Opacity(opacity: 0.2, child: _pedidoWidget(context, pedidos[e])),
        ),
        feedback: _feedbackPedidoWidget(pedidos, e),
        child: _pedidoWidget(context, pedidos[e]));
  }

  Widget _feedbackPedidoWidget(List<PedidoModel> pedidos, int e) {
    return Transform.rotate(
      angle: -pi / 200 * -5,
      child: Opacity(
        opacity: 0.8,
        child: Material(
            child: IntrinsicHeight(
          child:
              SizedBox(width: 290, child: _pedidoWidget(context, pedidos[e])),
        )),
      ),
    );
  }

  Widget _pedidoWidget(BuildContext context, PedidoModel pedido) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pedido.tags.isNotEmpty) ...[
            _tagsWidget(pedido),
            const H(8),
          ],
          Text(pedido.localizador),
          const H(8),
          _detailsWidget(pedido)
        ],
      ),
    );
  }

  Wrap _tagsWidget(PedidoModel pedido) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      children: pedido.tags.map((e) => _tagWidget(e)).toList(),
    );
  }

  Container _tagWidget(TagModel e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration:
          BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        e.nome,
        style: TextStyle(
          color: e.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailsWidget(PedidoModel pedido) {
    return Wrap(
      children: [
        if (pedido.deliveryAt != null)
          _detailWidget(
            Icons.timer_outlined,
            value: pedido.deliveryAt!.toddMM(),
          ),
      ],
    );
  }

  Widget _detailWidget(IconData icon, {String? value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF787C86),
          size: 14,
        ),
        if (value != null) ...[
          const W(4),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF787C86), fontSize: 12),
          ),
        ]
      ],
    );
  }
}
