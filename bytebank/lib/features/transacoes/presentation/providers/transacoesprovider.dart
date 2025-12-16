import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/features/saldo/presentation/providers/saldoprovider.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';

//Provider para o mês/ano selecionado (filtro)
final mesTransacaoSelecionadoProvider = StateProvider<String?>((ref) => null);

//Notifier que gerencia a lista de meses disponíveis para filtro
class MesesComTransacoesNotifier extends Notifier<List<String>> {
    @override
    List<String> build() {
        // Inicializa buscando os meses
        fetchMesesComTransacoes();
        return [];
    }
    
    Future<void> fetchMesesComTransacoes() async {
        final dbRef = FirebaseDatabase.instance.ref("transacoes");
        final snapshot = await dbRef.get();
        
        if (snapshot.exists) {
            final Map<dynamic, dynamic>? dados = snapshot.value as Map?;
            if (dados != null) {
                final meses = dados.keys.cast<String>().toList();
                meses.sort();
                state = meses; // Atualiza o estado
            }
        } else {
            state = [];
        }
    }
}

final mesesComTransacoesProvider = NotifierProvider<MesesComTransacoesNotifier, List<String>>(MesesComTransacoesNotifier.new);

// Notifier principal que gerencia a lista de Transacoes - Async
class TransacoesNotifier extends AsyncNotifier<List<TransacaoModel>> {

  @override
  Future<List<TransacaoModel>> build() async {
    // Observa o AuthProvider e o mês selecionado.
    final authState = ref.watch(authProvider);
    final mesAno = ref.watch(mesTransacaoSelecionadoProvider);

    if (!authState.isAuthenticated) {
      return [];
    }
    
    return _buscarTransacoes(authState.userId, mesAno: mesAno);
  }
  
  Future<List<TransacaoModel>> _buscarTransacoes(String userId, {String? mesAno}) async {
    // Lógica adaptada da função original
    final List<TransacaoModel> transacoes = [];
    final dbRef = FirebaseDatabase.instance.ref("transacoes");

    final mesAtual = mesAno ??
        "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";

    final snapshot = await dbRef.child(mesAtual).get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic>? dadosDoMes = snapshot.value as Map?;
      if (dadosDoMes != null) {
        dadosDoMes.forEach((dia, dadosDoDia) {
          if (dadosDoDia is Map && dadosDoDia.containsKey(userId)) {
            final Map<dynamic, dynamic> transacoesMap = dadosDoDia[userId];

            transacoesMap.forEach((id, dadosDaTransacao) {
              
              try {
                // Combina dados para satisfazer o TransacaoModel.fromMap
                final Map<dynamic, dynamic> fullMap = {
                    ...dadosDaTransacao,
                    'idTransacao': id, 
                    'data': "$dia-${mesAtual.substring(0, 2)}-${mesAtual.substring(3)}",
                    'hora': dadosDaTransacao['hora'] ?? '00:00:00',
                    'saldo': dadosDaTransacao['saldo'] ?? 0, 
                    'saldoAnterior': dadosDaTransacao['saldoAnterior'] ?? 0, 
                    'status': dadosDaTransacao['status'] ?? 'Concluída',
                    'historico': dadosDaTransacao['historico'] ?? [],
                };
                
                final transacao = TransacaoModel.fromMap(fullMap);
                transacoes.add(transacao);

              } catch (e) {
                debugPrint('Erro ao parsear TransacaoModel: $e. Dados: $dadosDaTransacao');
              }
            });
          }
        });
      }
    }
    
    return transacoes;
  }
  
  // Método de adição de transação
  Future<void> adicionarTransacao(
      TransacaoModel transacao, {File? comprovante}) async {
    
    // Define o estado para loading enquanto a operação ocorre
    state = const AsyncValue.loading();
    
    // Obtém o userId do AuthProvider
    final userId = ref.read(authProvider).userId;
    if (userId.isEmpty) {
        throw Exception("Usuário não autenticado.");
    }

    String? anexoUrl = transacao.anexoUrl;

    // Upload de comprovante
    //TODO: Aqui na verdade, eu preciso alterar, pois o que vou enviar é apenas o URL do arquivo, e não o arquivo em si.
    if (comprovante != null) {
      final idToUse = transacao.idTransacao.isNotEmpty ? transacao.idTransacao : DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('comprovantes')
          .child(userId)
          .child(idToUse);

      final uploadTask = storageRef.putFile(comprovante);
      final snapshot = await uploadTask.whenComplete(() {});
      anexoUrl = await snapshot.ref.getDownloadURL();
    }

    //Lógica de salvar no Realtime DB e Firestore
    //TODO: Refatorar, pois não uso Firestore. Deve salvar Apenas no Realtime DB.
    final idTransacaoToUse = transacao.idTransacao.isNotEmpty ? transacao.idTransacao : DateTime.now().millisecondsSinceEpoch.toString();
    final dataAtual = DateTime.now();
    final mesAno = DateFormat("MM-yyyy").format(dataAtual); 
    final dia = DateFormat("dd").format(dataAtual); 
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    final dbRef = FirebaseDatabase.instance
        .ref("transacoes")
        .child(mesAno)
        .child(dia)
        .child(userId)
        .child(idTransacaoToUse);

    final transacaoMap = {
      ...transacao.toMap(), 
      'anexoUrl': anexoUrl,
    };

    await dbRef.set(transacaoMap);

    //Atualizar saldo no Realtime DB
    final contaRef = FirebaseDatabase.instance.ref().child('contas').child(userId);
    await contaRef.update({ 'saldo': transacao.saldo }); 
    
    // Invalida os Providers para forçar o recarregamento
    ref.invalidateSelf();
    ref.read(saldoProvider.notifier).atualizarSaldo(transacao.saldo.toDouble());
    ref.read(mesesComTransacoesProvider.notifier).fetchMesesComTransacoes();
  }
}

final transacoesProvider = AsyncNotifierProvider<TransacoesNotifier, List<TransacaoModel>>(TransacoesNotifier.new);