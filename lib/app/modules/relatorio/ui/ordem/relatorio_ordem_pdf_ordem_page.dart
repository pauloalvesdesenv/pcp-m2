import 'dart:typed_data';

import 'package:aco_plus/app/core/client/firestore/collections/ordem/models/ordem_model.dart';
import 'package:aco_plus/app/core/components/pdf_divisor.dart';
import 'package:aco_plus/app/core/utils/app_colors.dart';
import 'package:aco_plus/app/modules/relatorio/view_models/relatorio_ordem_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RelatorioOrdemPdfOrdemPage {
  final RelatorioOrdemModel model;
  RelatorioOrdemPdfOrdemPage(this.model);

  pw.Widget build(Uint8List bytes) => pw.Column(
        children: [
          pw.Image(pw.MemoryImage(bytes), width: 60, height: 60),
          pw.SizedBox(height: 24),
          pw.Text('RELATÓRIO DE ORDEM DE PRODUÇÃO ${model.ordem.id}'),
          pw.SizedBox(height: 16),
          _itemHeader(model),
          pw.SizedBox(height: 24),
          _itemRelatorio(model.ordem),
        ],
      );

  pw.Widget _itemRelatorio(OrdemModel ordem) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(Colors.white.value),
        border: pw.Border.all(
            color: PdfColor.fromInt(Colors.grey[700]!.value), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                  child: pw.Text(ordem.id,
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(AppColors.black.value)))),
              pw.Text(
                  DateFormat("'Criado 'dd/MM/yyyy' às 'HH:mm")
                      .format(ordem.createdAt),
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.normal,
                      color: PdfColor.fromInt(AppColors.black.value))),
            ],
          ),
          _itemInfo('Bitola', '${ordem.produto.descricaoReplaced}mm'),
          PdfDivisor.build(),
          for (final produto in ordem.produtos)
            pw.Column(
              children: [
                _itemInfo('${produto.cliente.nome} - ${produto.obra.descricao}',
                    '${produto.qtde} kg'),
                PdfDivisor.build(
                  color: Colors.grey[200],
                ),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _itemHeader(RelatorioOrdemModel relatorio) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(Colors.white.value),
        border: pw.Border.all(
            color: PdfColor.fromInt(Colors.grey[700]!.value), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // pw.Text(relatorio.status.label,
          //     style: pw.TextStyle(
          //         fontSize: 11,
          //         fontWeight: pw.FontWeight.normal,
          //         color: PdfColor.fromInt(AppColors.black.value))),
          // pw.SizedBox(height: 8),
          // _itemInfo(
          //     'Data Criação Relatório',
          //     DateFormat("dd/MM/yyyy' ás 'HH:mm")
          //         .format(relatorio.createdAt)
          //         .toString()),
          // PdfDivisor.build(
          //   color: Colors.grey[200],
          // ),
          // _itemInfo('Quantidade Total Bitolas',
          //     '${relatorioCtrl.getOrdemTotal()} Kg'),
          // PdfDivisor.build(
          //   color: Colors.grey[200],
          // ),
          if (relatorio.dates != null)
            _itemInfo('Período',
                '${DateFormat("dd/MM/yyyy").format(relatorio.dates!.start)} - ${DateFormat("dd/MM/yyyy").format(relatorio.dates!.end)}'),
          // _itemInfo('Quantidade Total de Bitolas',
          //     "${relatorio.pedidos.fold<double>(0, (a, b) => a + (b.produtos.fold(0, (c, d) => c + d.qtde))).toStringAsFixed(2)} kg"),
          PdfDivisor.build(
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  pw.Widget _itemInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(Colors.grey[800]!.value))),
          ),
          pw.Expanded(
              flex: 2,
              child: pw.Text(
                value,
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.normal,
                    color: PdfColor.fromInt(Colors.grey[800]!.value)),
                textAlign: pw.TextAlign.end,
              ))
        ],
      ),
    );
  }
}
