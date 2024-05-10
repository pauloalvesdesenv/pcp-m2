import 'package:aco_plus/app/core/client/firestore/collections/ordem/models/ordem_model.dart';
import 'package:flutter/material.dart';

enum RelatorioOrdemType {
  STATUS,
  ORDEM,
}

extension RelatorioOrdemTypeExt on RelatorioOrdemType {
  String get label {
    switch (this) {
      case RelatorioOrdemType.STATUS:
        return 'Status';
      case RelatorioOrdemType.ORDEM:
        return 'Ordem';
    }
  }
}

enum RelatorioOrdemStatus {
  AGUARDANDO_PRODUCAO,
  EM_PRODUCAO,
  PRODUZIDAS,
}

extension RelatorioOrdemStatusExt on RelatorioOrdemStatus {
  String get label {
    switch (this) {
      case RelatorioOrdemStatus.AGUARDANDO_PRODUCAO:
        return 'Aguardando Produção';
      case RelatorioOrdemStatus.EM_PRODUCAO:
        return 'Em Produção';
      case RelatorioOrdemStatus.PRODUZIDAS:
        return 'Produzidas';
    }
  }
}

class RelatorioOrdemViewModel {
  RelatorioOrdemType? type;
  RelatorioOrdemStatus? status;
  DateTimeRange? dates;
  RelatorioOrdemModel? relatorio;
  OrdemModel? ordem;
}

class RelatorioOrdemModel {
  late RelatorioOrdemStatus status;
  late List<OrdemModel> ordens;
  late DateTimeRange? dates;
  late OrdemModel ordem;
  final DateTime createdAt = DateTime.now();

  RelatorioOrdemModel.status(this.status, this.ordens, {this.dates});
  RelatorioOrdemModel.ordem(this.ordem);
}
