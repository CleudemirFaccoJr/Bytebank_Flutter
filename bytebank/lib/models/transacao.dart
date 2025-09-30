import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

typedef tipoTransacao = DropdownMenuEntry<TipoTransacao>;

enum TipoTransacao {
  selecioneTransacao,
  deposito,
  transferencia,
  pagamento,
  investimento,
}

typedef categoriaTransacao = DropdownMenuEntry<CategoriaTransacao>;

enum CategoriaTransacao {
  selecioneCategoria,
  saude,
  lazer,
  investimento,
  transporte,
  alimentacao,
  outros,
}

class Transacao {
  final String tipo;
  final double valor;
  final String idconta;
  final double saldoAnterior;
  final String descricao;
  final String categoria;
  final String data;
  final String hora;
  final String status;
  final String? idTransacao;
  final String? anexoUrl;
  final List<Map<String, dynamic>>? historico;

  final double saldoFinal; 

  final String idUnico = const Uuid().v4();

  Transacao({
    required this.tipo,
    required this.valor,
    required this.idconta,
    required this.saldoAnterior,
    required this.descricao,
    required this.categoria,
    this.idTransacao,
    this.anexoUrl,
    String modo = "nova",
    this.historico,

    required this.saldoFinal, 
  })  : 
    data = DateFormat('dd-MM-yyyy').format(DateTime.now()),
    hora = DateFormat('HH:mm:ss').format(DateTime.now()),
    status = modo == "edicao" ? "Editada" : "Ativa";


  // Método para converter o objeto Transacao em um Map para o Firebase
  Map<String, dynamic> toMap() {
    return {
      'idTransacao': idTransacao,
      'tipoTransacao': tipo,
      'valor': valor,
      'saldoAnterior': saldoAnterior,
      'saldo': saldoFinal, 
      'data': data,
      'hora': hora,
      'status': status,
      'descricao': descricao,
      'categoria': categoria,
      'anexoUrl': anexoUrl,
      'historico': historico,
    };
  }

  Future<void> registrar({File? anexoFile}) async {
  final dataAtual = DateTime.now();
  final mesVigente = DateFormat('MM-yyyy').format(dataAtual); 

  final String idTransacaoToUse = idTransacao ?? 
      FirebaseDatabase.instance.ref().push().key!;

  String? finalAnexoUrl = anexoUrl;

  if (anexoFile != null) {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('comprovantes')
          .child(idconta)
          .child('$idTransacaoToUse.jpg');

      final uploadTask = ref.putFile(anexoFile);
      final snapshot = await uploadTask;
      finalAnexoUrl = await snapshot.ref.getDownloadURL();
      print("Anexo enviado com sucesso. URL: $finalAnexoUrl");
    } catch (e) {
      print("Erro ao fazer upload do anexo: $e");
      throw Exception("Erro ao enviar o comprovante. Tente novamente.");
    }
  }

  final transacoesRef = FirebaseDatabase.instance.ref()
      .child('transacoes')
      .child(mesVigente)
      .child(data)
      .child(idconta)
      .child(idTransacaoToUse);

  final contaRef = FirebaseDatabase.instance.ref().child('contas').child(idconta);

  try {
    final transacaoData = {
      ...toMap(),
      'idTransacao': idTransacaoToUse,
      'anexoUrl': finalAnexoUrl,
    };

    await transacoesRef.set(transacaoData);
    await contaRef.update({'saldo': saldoFinal});

    print("Transação registrada e saldo atualizado com sucesso.");
  } on FirebaseException catch (e) {
    print("Erro do Firebase ao registrar transação: ${e.message}");
    throw Exception("Erro ao registrar a transação. Tente novamente.");
  } catch (error) {
    print("Erro inesperado ao registrar transação: $error");
    throw Exception("Erro inesperado ao registrar a transação.");
  }
}

  Future<void> atualizarTransacao(DateTime mesSelecionado) async {
      // Implementação da atualização...
  }
  
  
  Future<void> excluirTransacao(DateTime mesSelecionado) async {
    // Implementação da exclusão...
  }
}
