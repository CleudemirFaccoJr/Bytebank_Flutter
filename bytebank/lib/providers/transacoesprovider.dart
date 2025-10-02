import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:bytebank/models/transacao.dart';

class TransacoesProvider with ChangeNotifier {
  List<Transacao> _transacoes = [];
  List<Transacao> get transacoes => _transacoes;

  List<String> _mesesComTransacoes = [];
  List<String> get mesesComTransacoes => _mesesComTransacoes;


  Future<void> buscarTransacoes(String userId, {String? mesAno}) async {
    _transacoes = [];
  _transacoes.clear();

  final dbRef = FirebaseDatabase.instance.ref("transacoes");
   

  final mesAtual = mesAno ??
      "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";

  final snapshot = await dbRef.child(mesAtual).get();

  if (snapshot.exists) {
    debugPrint("Transações encontradas para $mesAtual");

    final Map<dynamic, dynamic>? dadosDoMes = snapshot.value as Map?;
    if (dadosDoMes != null) {
      
      dadosDoMes.forEach((dia, dadosDoDia) {
        
        if (dadosDoDia is Map && dadosDoDia.containsKey(userId)) {
          final Map<dynamic, dynamic> transacoesMap = dadosDoDia[userId];
          
          transacoesMap.forEach((id, dadosDaTransacao) {
            
            // CONSTRUÇÃO MANUAL DO OBJETO TRANSACAO USANDO PLACEHOLDERS
            final transacao = Transacao(
              tipo: dadosDaTransacao['tipoTransacao'] as String,
              valor: (dadosDaTransacao['valor'] as num).toDouble(),
              descricao: dadosDaTransacao['descricao'] as String,
              categoria: dadosDaTransacao['categoria'] as String,
              anexoUrl: dadosDaTransacao['anexoUrl'] as String?,
              idTransacao: id,
              
              idconta: userId,
              saldoAnterior: 0.0,
              saldoFinal: 0.0,
            );
            
            _transacoes.add(transacao);
          });
        }
      });
      
      if (_transacoes.isNotEmpty) {
        debugPrint("Total de transações carregadas: ${_transacoes.length}");
        for (var t in _transacoes) {
          debugPrint("ID: ${t.idTransacao}, Tipo: ${t.tipo}, Valor: ${t.valor}, Data: ${t.data}, Categoria: ${t.categoria}");
        }
      } else {
        debugPrint("Nenhuma transação encontrada para este usuário em $mesAtual");
      }
    }
  } else {
    debugPrint("Nenhuma transação encontrada no Firebase para $mesAtual");
  }

  notifyListeners();
}


  Future<void> fetchMesesComTransacoes() async {
    final dbRef = FirebaseDatabase.instance.ref("transacoes");
    final snapshot = await dbRef.get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic>? dados = snapshot.value as Map?;
      if (dados != null) {
        _mesesComTransacoes = dados.keys.cast<String>().toList();
        _mesesComTransacoes.sort();
      }
    } else {
      _mesesComTransacoes = [];
    }
    notifyListeners();
  }

  Future<void> adicionarTransacao(
      Transacao transacao, String userId, {File? comprovante}) async {
    String? anexoUrl = transacao.anexoUrl;

    if (comprovante != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('comprovantes')
          .child(userId)
          .child(transacao.idTransacao ?? DateTime.now().millisecondsSinceEpoch.toString());

      final uploadTask = storageRef.putFile(comprovante);
      final snapshot = await uploadTask.whenComplete(() {});
      anexoUrl = await snapshot.ref.getDownloadURL();
    }

    final idTransacaoToUse = transacao.idTransacao ?? DateTime.now().millisecondsSinceEpoch.toString();
    final dataAtual = DateTime.now();
    final mesAno = DateFormat("MM-yyyy").format(dataAtual); 
    final dia = DateFormat("dd").format(dataAtual); 
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    
    final dbRef = FirebaseDatabase.instance
        .ref("transacoes")
        .child(mesAno)
        .child(dia)
        .child(userId)
        .child(idTransacaoToUse);

    final transacaoMap = {
      'idTransacao': idTransacaoToUse,
      'valor': transacao.valor,
      'tipoTransacao': transacao.tipo,
      'categoria': transacao.categoria,
      'data': transacao.data,
      'descricao': transacao.descricao,
      'anexoUrl': anexoUrl,
      'hora': transacao.hora,
    };

    await dbRef.set(transacaoMap);

    try {
      //Cria a referência da coleção para o usuário no Firestore
      CollectionReference userTransacoesRef = _firestore
          .collection('usuarios') 
          .doc(userId)           
          .collection('transacoes');
      
      //Prepara o mapa com um Timestamp unificado para ordenação e busca
      final firestoreMap = {
        ...transacaoMap, // Reutiliza os dados base
        'anexoUrl': anexoUrl, // Garante que a URL mais recente seja usada
        'dataHora': dataAtual, // Usando o objeto DateTime nativo, Firestore salva como Timestamp
      };

      //Salva no Firestore usando o mesmo ID de transação
      await userTransacoesRef.doc(idTransacaoToUse).set(firestoreMap);
      debugPrint("Transação replicada com sucesso para o Firestore!");
    } catch (e) {
      debugPrint("AVISO: Falha ao replicar transação para o Firestore: $e");
      // Tratamento de erro leve: A transação principal no RTDB já foi salva.
    }

    final contaRef = FirebaseDatabase.instance.ref().child('contas').child(userId);
    await contaRef.update({ 'saldo': transacao.saldoFinal });
  }
}