import 'package:aco_plus/app/core/client/firestore/collections/pedido/enums/pedido_status.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/enums/pedido_tipo.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_history_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_produto_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_produto_status_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_status_model.dart';
import 'package:aco_plus/app/core/models/app_stream.dart';
import 'package:aco_plus/app/modules/pedido/pedido_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoCollection {
  static final PedidoCollection _instance = PedidoCollection._();

  PedidoCollection._();

  factory PedidoCollection() => _instance;
  String name = 'pedidos';

  AppStream<List<PedidoModel>> dataStream = AppStream<List<PedidoModel>>();
  List<PedidoModel> get data => dataStream.value;

  CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection(name);

  Future<void> fetch({bool lock = true, GetOptions? options}) async {
    _isStarted = false;
    await start(lock: false, options: options);
    _isStarted = true;
  }

  bool _isStarted = false;
  Future<void> start({bool lock = true, GetOptions? options}) async {
    if (_isStarted && lock) return;
    _isStarted = true;
    final data = await FirebaseFirestore.instance.collection(name).get();
    final pedidos =
        data.docs.map((e) => PedidoModel.fromMap(e.data())).toList();

    dataStream.add(pedidos);
  }

  bool _isListen = false;
  Future<void> listen({
    Object? field,
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) async {
    if (_isListen) return;
    _isListen = true;
    (field != null
            ? collection.where(
                field,
                isEqualTo: isEqualTo,
                isNotEqualTo: isNotEqualTo,
                isLessThan: isLessThan,
                isLessThanOrEqualTo: isLessThanOrEqualTo,
                isGreaterThan: isGreaterThan,
                isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
                arrayContains: arrayContains,
                arrayContainsAny: arrayContainsAny,
                whereIn: whereIn,
                whereNotIn: whereNotIn,
                isNull: isNull,
              )
            : collection)
        .snapshots()
        .listen((e) {
      final data = e.docs.map((e) => PedidoModel.fromMap(e.data())).toList();
      dataStream.add(data);
    });
  }

  PedidoModel getById(String id) => data.singleWhere((e) => e.id == id);

  PedidoProdutoModel getProdutoByPedidoId(String pedidoId, String produtoId) =>
      getById(pedidoId).produtos.firstWhere((e) => e.id == produtoId);

  Future<PedidoModel?> add(PedidoModel model) async {
    await collection.doc(model.id).set(model.toMap());
    return model;
  }

  Future<PedidoModel?> update(PedidoModel model) async {
    await collection.doc(model.id).update(model.toMap());
    return model;
  }

  Future<void> delete(PedidoModel model) async {
    await collection.doc(model.id).delete();
  }

  Future<void> updateAll(List<PedidoModel> pedidos) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var pedido in pedidos) {
      batch.update(collection.doc(pedido.id), pedido.toMap());
    }
    await batch.commit();
  }

  Future<void> updateProdutoStatus(
      PedidoProdutoModel produto, PedidoProdutoStatus status) async {
    final pedido = getById(produto.pedidoId);

    pedido.produtos
        .firstWhere((element) => element.id == produto.id)
        .statusess
        .add(PedidoProdutoStatusModel.create(status));
    return await collection.doc(pedido.id).update(pedido.toMap());
  }

  Future<PedidoModel?> updatePedidoStatus(PedidoProdutoModel produto) async {
    final pedido = getById(produto.pedidoId);
    final status = PedidoStatusModel.create(getPedidoStatusByProduto(pedido));
    if (status.status == pedido.status) return null;
    pedido.statusess.add(status);
    await collection.doc(pedido.id).update(pedido.toMap());
    return pedido;
  }

  PedidoStatus getPedidoStatusByProduto(PedidoModel pedido) {
    bool isAllDone = pedido.produtos
        .every((e) => e.status.status == PedidoProdutoStatus.pronto);
    if (isAllDone) {
      return pedido.tipo == PedidoTipo.cd
          ? PedidoStatus.pronto
          : PedidoStatus.aguardandoProducaoCDA;
    } else {
      bool isAllAguardandoProducao = pedido.produtos.every(
          (e) => e.status.status == PedidoProdutoStatus.aguardandoProducao);

      return isAllAguardandoProducao
          ? PedidoStatus.aguardandoProducaoCD
          : PedidoStatus.produzindoCD;
    }
  }
}
