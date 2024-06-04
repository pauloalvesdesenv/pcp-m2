import 'package:aco_plus/app/core/client/firestore/collections/cliente/cliente_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/enums/pedido_status.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/enums/pedido_tipo.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_status_model.dart';
import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/components/comment/comment_quill_model.dart';
import 'package:aco_plus/app/core/enums/sort_type.dart';
import 'package:aco_plus/app/core/extensions/date_ext.dart';
import 'package:aco_plus/app/core/models/text_controller.dart';
import 'package:aco_plus/app/core/services/hash_service.dart';
import 'package:aco_plus/app/modules/pedido/view_models/pedido_produto_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class PedidoUtils {
  final TextController search = TextController();
  SortType sortType = SortType.alfabetic;
  SortOrder sortOrder = SortOrder.asc;
  CommentQuillModel quill = CommentQuillModel();
}

class PedidoCreateModel {
  final String id;
  final TextController localizador = TextController();
  final TextController nome = TextController();
  final TextController descricao = TextController();
  final TextController clienteEC = TextController();
  ClienteModel? cliente;
  ClienteModel? clienteAdd;
  ObraModel? obra;
  PedidoTipo? tipo;
  PedidoProdutoCreateModel produto = PedidoProdutoCreateModel();
  FocusNode produtoFocus = FocusNode();
  final GlobalKey produtoKey = GlobalKey();
  List<PedidoProdutoCreateModel> produtos = [];
  DateTime? deliveryAt;
  ExpansionTileController tileController = ExpansionTileController();

  late bool isEdit;

  PedidoCreateModel()
      : id = HashService.get,
        isEdit = false;

  String getDetails() {
    List<String> localizador = [];
    localizador.add(this.localizador.text.isEmpty
        ? 'Localizador não informado'
        : this.localizador.text);
    localizador.add(tipo?.label ?? 'Tipo não informado');
    localizador.add(
        descricao.text.isEmpty ? 'Descrição não informada' : descricao.text);
    localizador.add(cliente?.nome ?? 'Cliente não informado');
    localizador.add(obra?.descricao ?? 'Obra não informada');
    localizador.add(deliveryAt == null
        ? 'Data de entrega não informada'
        : deliveryAt!.text());
    return localizador.join(' - ');
  }

  PedidoCreateModel.edit(PedidoModel pedido)
      : id = pedido.id,
        isEdit = true {
    localizador.text = pedido.localizador;
    descricao.text = pedido.descricao;
    cliente = FirestoreClient.clientes.getById(pedido.cliente.id);
    obra = cliente?.obras.firstWhereOrNull((e) => e.id == pedido.obra.id);
    tipo = pedido.tipo;
    produtos =
        pedido.produtos.map((e) => PedidoProdutoCreateModel.edit(e)).toList();
    deliveryAt = pedido.deliveryAt;
  }

  PedidoModel toPedidoModel(PedidoModel? pedido) => PedidoModel(
        id: id,
        tipo: tipo!,
        descricao: descricao.text,
        statusess: [
          PedidoStatusModel(
              id: HashService.get,
              status: PedidoStatus.produzindoCD,
              createdAt: pedido?.statusess.first.createdAt ?? DateTime.now())
        ],
        localizador: localizador.text,
        createdAt: pedido?.createdAt ?? DateTime.now(),
        cliente: cliente!,
        obra: obra!,
        produtos: produtos
            .map((e) => e.toPedidoProdutoModel(id, cliente!, obra!).copyWith())
            .toList(),
        deliveryAt: deliveryAt,
        steps: [],
        tags: [],
        checks: [],
        comments: [],
        index: FirestoreClient.pedidos.data.length
      );
}
