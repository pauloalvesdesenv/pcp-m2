import 'package:aco_plus/app/core/client/firestore/collections/cliente/cliente_model.dart';
import 'package:aco_plus/app/core/enums/obra_status.dart';
import 'package:aco_plus/app/core/models/endereco_model.dart';
import 'package:aco_plus/app/core/services/hash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ObraUtils {
  final TextEditingController search = TextEditingController();
}

class ObraCreateModel {
  final String id;
  TextEditingController descricao = TextEditingController();
  MaskedTextController telefoneFixo = MaskedTextController(mask: '(00) 00000-0000');
  EnderecoModel? endereco;
  ObraStatus? status = ObraStatus.emAndamento;
  late bool isEdit;

  ObraCreateModel()
      : id = HashService.get,
        isEdit = false;

  ObraCreateModel.edit(ObraModel obra)
      : id = obra.id,
        isEdit = true {
    descricao.text = obra.descricao;
    endereco = obra.endereco;
    status = obra.status;
  }

  ObraModel toObraModel() => ObraModel(
        id: id,
        descricao: descricao.text,
        endereco: endereco,
        status: status!,
        telefoneFixo: telefoneFixo.text,
      );
}
