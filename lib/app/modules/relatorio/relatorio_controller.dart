import 'dart:convert';
import 'dart:html' as html;

import 'package:aco_plus/app/core/client/firestore/collections/ordem/models/ordem_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/enums/pedido_status.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_produto_model.dart';
import 'package:aco_plus/app/core/client/firestore/collections/pedido/models/pedido_produto_status_model.dart';
import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/extensions/date_ext.dart';
import 'package:aco_plus/app/core/models/app_stream.dart';
import 'package:aco_plus/app/modules/relatorio/ui/ordem/relatorio_ordem_pdf_ordem_page.dart';
import 'package:aco_plus/app/modules/relatorio/ui/ordem/relatorio_ordem_pdf_status_page.dart';
import 'package:aco_plus/app/modules/relatorio/ui/pedido/relatorio_pedido_pdf_page.dart';
import 'package:aco_plus/app/modules/relatorio/view_models/relatorio_ordem_view_model.dart';
import 'package:aco_plus/app/modules/relatorio/view_models/relatorio_pedido_view_model.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final relatorioCtrl = PedidoController();

class PedidoController {
  static final PedidoController _instance = PedidoController._();

  PedidoController._();

  factory PedidoController() => _instance;

  final AppStream<RelatorioPedidoViewModel> pedidoViewModelStream =
      AppStream<RelatorioPedidoViewModel>();
  RelatorioPedidoViewModel get pedidoViewModel => pedidoViewModelStream.value;

  void onCreateRelatorioPedido() {
    final model = RelatorioPedidoModel(
      pedidoViewModel.cliente!,
      pedidoViewModel.status!,
      FirestoreClient.pedidos.data
          .where((e) =>
              pedidoViewModel.status == RelatorioPedidoStatus.produzindo
                  ? e.statusess.last.status != PedidoStatus.pronto
                  : e.statusess.last.status == PedidoStatus.pronto)
          .toList(),
    );
    pedidoViewModel.relatorio = model;
    pedidoViewModelStream.update();
  }

  Future<void> onExportRelatorioPedidoPDF() async {
    final pdf = pw.Document();

    final img = await rootBundle.load('assets/images/logo.png');
    final imageBytes = img.buffer.asUint8List();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) =>
            RelatorioPedidoPdfPage(pedidoViewModel.relatorio!)
                .build(imageBytes)));

    var savedFile = await pdf.save();
    List<int> fileInts = List.from(savedFile);
    html.AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
      ..setAttribute("download",
          "m2_relatorio_cliente_${pedidoViewModel.cliente?.nome.toLowerCase().replaceAll(' ', '_')}_status_${pedidoViewModel.status!.label.toLowerCase()}${DateTime.now().toFileName()}.pdf")
      ..click();
  }

  final AppStream<RelatorioOrdemViewModel> ordemViewModelStream =
      AppStream<RelatorioOrdemViewModel>();
  RelatorioOrdemViewModel get ordemViewModel => ordemViewModelStream.value;

  void onCreateRelatorio() {
    if (ordemViewModel.type == RelatorioOrdemType.STATUS) {
      onCreateRelatorioOrdemStatus();
    } else {
      onCreateRelatorioOrdem();
    }
  }

  void onCreateRelatorioOrdemStatus() {
    List<OrdemModel> ordens = FirestoreClient.ordens.data;
    for (final ordem in ordens) {
      ordem.produtos = ordem.produtos
          .where((e) => _whereProductStatus(e, ordemViewModel.status!))
          .toList();
    }
    ordens.removeWhere((e) => e.produtos.isEmpty);
    if (ordemViewModel.dates != null) {
      ordens = ordens
          .where((e) =>
              e.createdAt.isAfter(ordemViewModel.dates!.start) &&
              e.createdAt.isBefore(ordemViewModel.dates!.end))
          .toList();
    }
    final model = RelatorioOrdemModel.status(
      ordemViewModel.status!,
      ordens,
      dates: ordemViewModel.dates,
    );

    ordemViewModel.relatorio = model;
    ordemViewModelStream.update();
  }

  void onCreateRelatorioOrdem() {
    final model = RelatorioOrdemModel.ordem(
      ordemViewModel.ordem!,
    );

    ordemViewModel.relatorio = model;
    ordemViewModelStream.update();
  }

  bool _whereProductStatus(
      PedidoProdutoModel produto, RelatorioOrdemStatus status) {
    final productStatus = produto.statusess.last.status;
    switch (status) {
      case RelatorioOrdemStatus.AGUARDANDO_PRODUCAO:
        return [
          PedidoProdutoStatus.separado,
          PedidoProdutoStatus.aguardandoProducao
        ].contains(productStatus);
      case RelatorioOrdemStatus.EM_PRODUCAO:
        return productStatus == PedidoProdutoStatus.produzindo;
      case RelatorioOrdemStatus.PRODUZIDAS:
        return productStatus == PedidoProdutoStatus.pronto;
    }
  }

  double getOrdemTotal() {
    double qtde = 0;
    for (var orden in ordemViewModel.relatorio!.ordens) {
      for (var produto in orden.produtos) {
        qtde = qtde + produto.qtde;
      }
    }
    return double.parse(qtde.toStringAsFixed(2));
  }

  Future<void> onExportRelatorioOrdemPDF() async {
    final pdf = pw.Document();

    final img = await rootBundle.load('assets/images/logo.png');
    final imageBytes = img.buffer.asUint8List();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.undefined,
        build: (pw.Context context) =>
            (ordemViewModel.type == RelatorioOrdemType.ORDEM
                ? RelatorioOrdemPdfOrdemPage(ordemViewModel.relatorio!)
                    .build(imageBytes)
                : RelatorioOrdemPdfStatusPage(ordemViewModel.relatorio!)
                    .build(imageBytes))));

    var savedFile = await pdf.save();
    List<int> fileInts = List.from(savedFile);
    html.AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
      ..setAttribute("download",
          "m2_relatorio_bitola_status_${ordemViewModel.status!.label.toLowerCase()}${DateTime.now().toFileName()}.pdf")
      ..click();
  }
}
