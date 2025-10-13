import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      debugPrint("Anexo enviado com sucesso. URL: $finalAnexoUrl");
    } catch (e) {
      debugPrint("Erro ao fazer upload do anexo: $e");
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

    debugPrint("Transação registrada e saldo atualizado com sucesso.");
  } on FirebaseException catch (e) {
    debugPrint("Erro do Firebase ao registrar transação: ${e.message}");
    throw Exception("Erro ao registrar a transação. Tente novamente.");
  } catch (error) {
    debugPrint("Erro inesperado ao registrar transação: $error");
    throw Exception("Erro inesperado ao registrar a transação.");
  }
}

  Future<void> atualizarTransacao(
  // Dados da transação antes da edição
  Transacao transacaoOriginal, 
  // Arquivo do novo comprovante (se selecionado)
  File? novoComprovante, 
  // Se o usuário marcou para remover o comprovante que já existia
  bool removerComprovanteAtual
) async {
  if (idTransacao == null) {
    throw Exception("ID da transação é nulo. Não é possível atualizar.");
  }

  // Usar data e idconta originais para localizar o nó no Firebase
  final mesVigente = DateFormat('MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(transacaoOriginal.data));
  final diaOriginal = transacaoOriginal.data;
  final id = idTransacao!;
  String? novoAnexoUrl = anexoUrl;

  try {
    //Lógica de Comprovante
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('comprovantes')
        .child(idconta)
        .child('$id.jpg');

    if (removerComprovanteAtual && transacaoOriginal.anexoUrl != null) {
      // Excluir comprovante existente no Storage
      await storageRef.delete();
      novoAnexoUrl = null;
      debugPrint("Comprovante anterior removido do Storage.");
    } else if (novoComprovante != null) {
      // Substituir ou adicionar novo comprovante
      final uploadTask = storageRef.putFile(novoComprovante);
      final snapshot = await uploadTask;
      novoAnexoUrl = await snapshot.ref.getDownloadURL();
      debugPrint("Comprovante atualizado/adicionado. URL: $novoAnexoUrl");
    } else {
      // Mantém o anexoUrl original se não houve nem remoção nem novo upload
      novoAnexoUrl = transacaoOriginal.anexoUrl;
    }

    //Preparar Dados de Histórico
    final historicoAtual = transacaoOriginal.historico ?? [];
    
    //Registrar o estado anterior da transação
    final Map<String, dynamic> estadoAnterior = {
        'timestamp': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
        'acao': 'Edição da Transação',
        'dadosAntigos': {
            'tipoTransacao': transacaoOriginal.tipo,
            'valor': transacaoOriginal.valor,
            'descricao': transacaoOriginal.descricao,
            'categoria': transacaoOriginal.categoria,
            'anexoUrl': transacaoOriginal.anexoUrl,
            'status': transacaoOriginal.status,
        },
    };
    historicoAtual.add(estadoAnterior);

    //Atualizar dados no Realtime Database
    final transacaoRef = FirebaseDatabase.instance.ref()
        .child('transacoes')
        .child(mesVigente)
        .child(diaOriginal.substring(0, 2))
        .child(idconta)
        .child(id);

    // Usar a data original da transação. O status é 'Editada'.
    final Map<String, dynamic> dadosParaAtualizar = {
      'tipoTransacao': tipo,
      'valor': valor,
      'descricao': descricao,
      'categoria': categoria,
      'anexoUrl': novoAnexoUrl,
      'status': 'Editada',
      'saldo': saldoFinal,
      'historico': historicoAtual,
    };

    await transacaoRef.update(dadosParaAtualizar);
    
    //Duplicando pro Cloud
    try {
        final firestoreDocRef = FirebaseFirestore.instance
            .collection('usuarios') 
            .doc(idconta) // idconta é o userId, usado como chave do usuário
            .collection('transacoes')
            .doc(idTransacao); // idTransacao é o ID do documento

        // Prepara o mapa para o Firestore
        final firestoreUpdateMap = {
            ...dadosParaAtualizar, 
            // Adiciona/Atualiza o campo unificado de data/hora (Timestamp)
            'dataHora': DateFormat('dd-MM-yyyy HH:mm:ss').parse(
                '$data $hora:00'), // Cria um DateTime a partir dos campos existentes
        };

        // 1. Verifica a existência do documento
        final docSnapshot = await firestoreDocRef.get();
        
        if (!docSnapshot.exists) {
            // SE NÃO EXISTIR, usa set() para CADASTRAR/CRIAR
            await firestoreDocRef.set(firestoreUpdateMap);
            debugPrint("CFS: Transação cadastrada no Firestore.");
        } else {
            // SE EXISTIR, usa update() para ATUALIZAR
            await firestoreDocRef.update(firestoreUpdateMap);
            debugPrint("CFS: Transação atualizada no Firestore.");
        }

    } catch (e) {
        debugPrint("AVISO: Falha ao atualizar transação no Firestore: $e");
        // Loga o erro do Firestore, mas não impede o fluxo do RTDB
    }
    
    //Recálculo de Saldo
    
    debugPrint("Transação, anexo e histórico atualizados com sucesso.");
  } on FirebaseException catch (e) {
    debugPrint("Erro do Firebase ao atualizar transação: ${e.message}");
    throw Exception("Erro ao atualizar a transação. Tente novamente.");
  } catch (error) {
    debugPrint("Erro inesperado ao atualizar transação: $error");
    throw Exception("Erro inesperado ao atualizar a transação.");
  }
}


  
  
  Future<void> excluirTransacao() async {
   // Implementação da exclusão...
}
}