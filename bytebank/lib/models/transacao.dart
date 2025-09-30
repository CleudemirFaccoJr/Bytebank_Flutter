import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

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

  // O saldo final é calculado no método 'registrar', mas é bom tê-lo no construtor
  // se for passado externamente ou calculado antes.
  final double saldoFinal; 

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
    // O valor do saldo final deve ser passado ou calculado. 
    // Vamos calcular/passar o saldo final no Provider/Screen e atribuir aqui.
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

  // --- MÉTODOS DE INTERAÇÃO COM FIREBASE ---

  /// Registra uma nova transação no Realtime Database e atualiza o saldo da conta.
  /// Se 'anexoFile' for fornecido, faz o upload para o Storage antes de salvar a transação.
  Future<void> registrar({File? anexoFile}) async {
    final dataAtual = DateTime.now();
    // Formato 'MM-yyyy' para o nó principal (igual ao TS)
    final mesVigente = DateFormat('MM-yyyy').format(dataAtual); 
    
    // Gera um ID ou usa o que foi passado
    final String idTransacaoToUse = idTransacao ?? dataAtual.millisecondsSinceEpoch.toString(); 

    String? finalAnexoUrl = anexoUrl;

    // 1. UPLOAD DO ARQUIVO PARA O FIREBASE STORAGE (se houver)
    if (anexoFile != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('comprovantes')
            .child(idconta)
            .child('$idTransacaoToUse.jpg'); // Ou o tipo de arquivo apropriado

        final uploadTask = ref.putFile(anexoFile);
        final snapshot = await uploadTask;
        finalAnexoUrl = await snapshot.ref.getDownloadURL();
        print("Anexo enviado com sucesso. URL: $finalAnexoUrl");
      } catch (e) {
        print("Erro ao fazer upload do anexo: $e");
        throw Exception("Erro ao enviar o comprovante. Tente novamente.");
      }
    }

    // 2. REGISTRO NO REALTIME DATABASE
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
        'anexoUrl': finalAnexoUrl, // Garante que a URL final seja salva
      };

      await transacoesRef.set(transacaoData);

      // 3. ATUALIZAÇÃO DO SALDO DA CONTA
      await contaRef.update({ 'saldo': saldoFinal });

      print("Transação registrada e saldo atualizado com sucesso.");
    } on FirebaseException catch (e) {
      print("Erro do Firebase ao registrar transação: ${e.message}");
      throw Exception("Erro ao registrar a transação. Tente novamente.");
    } catch (error) {
      print("Erro inesperado ao registrar transação: $error");
      throw Exception("Erro inesperado ao registrar a transação.");
    }
  }

  // O método 'atualizarTransacao' e 'excluirTransacao' seguiriam uma lógica
  // similar ao método 'registrar', usando 'update' e 'remove' (ou 'set' do status).
  // Eles também precisariam de um tratamento especial para o Firebase Storage,
  // como remover o anexo anterior se a transação for excluída ou o anexo for trocado.

  // Exemplo de atualização (o objeto 'Transacao' seria instanciado com os novos dados)
  Future<void> atualizarTransacao(DateTime mesSelecionado) async {
      // Implementação da atualização...
  }
  
  // Exemplo de exclusão (que é uma 'soft delete' alterando o status)
  Future<void> excluirTransacao(DateTime mesSelecionado) async {
    // Implementação da exclusão...
  }
}
