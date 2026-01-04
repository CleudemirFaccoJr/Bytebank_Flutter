import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/features/transacoes/data/models/transacao_historicomodel.dart';
import 'package:bytebank/features/saldo/presentation/providers/saldoprovider.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';
import 'package:bytebank/services/cache/app_cache_manager..dart';

//Provider para o mês/ano selecionado (filtro)
final mesTransacaoSelecionadoProvider = StateProvider<String?>((ref) => null);

// Estado para o texto de busca
final buscaTransacaoProvider = StateProvider<String>((ref) => "");

// Estado para o filtro de tipo (Todas, Entrada, Saída)
enum FiltroTipo { todas, entrada, saida }
final filtroTipoProvider = StateProvider<FiltroTipo>((ref) => FiltroTipo.todas);

// Provider que aplica a lógica de filtro sobre a lista original
final transacoesFiltradasProvider = Provider<AsyncValue<List<TransacaoModel>>>((ref) {
  final transacoesAsync = ref.watch(transacoesProvider);
  final busca = ref.watch(buscaTransacaoProvider).toLowerCase();
  final filtroTipo = ref.watch(filtroTipoProvider);

  return transacoesAsync.whenData((lista) {
    return lista.where((t) {
      //Filtro de exclusão lógica
      if (t.status == 'excluida') return false;

      //Filtro de Busca
      final atendeBusca = t.descricao.toLowerCase().contains(busca) || 
                          t.categoria.label.toLowerCase().contains(busca);

      //Filtro de Tipo (Entrada/Saída)
      bool atendeTipo = true;
      if (filtroTipo == FiltroTipo.entrada) atendeTipo = t.tipoTransacao == TipoTransacao.deposito;
      if (filtroTipo == FiltroTipo.saida) atendeTipo = t.tipoTransacao != TipoTransacao.deposito;

      return atendeBusca && atendeTipo;
    }).toList();
  });
});

//Notifier que gerencia a lista de meses disponíveis para filtro
class MesesComTransacoesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final dbRef = FirebaseDatabase.instance.ref("transacoes");
    final snapshot = await dbRef.get();

    if (!snapshot.exists) return [];

    final dados = snapshot.value as Map<dynamic, dynamic>;
    final meses = dados.keys.cast<String>().toList()
      ..sort((a, b) => b.compareTo(a));

      meses.sort((a, b) {
      final dateA = DateFormat("MM-yyyy").parse(a);
      final dateB = DateFormat("MM-yyyy").parse(b);
      return dateB.compareTo(dateA); // Recentes primeiro
    });

    return meses;
  }
}

final mesesComTransacoesProvider =
    AsyncNotifierProvider<MesesComTransacoesNotifier, List<String>>(
        MesesComTransacoesNotifier.new);

// Notifier principal que gerencia a lista de Transacoes - Async
class TransacoesNotifier extends AsyncNotifier<List<TransacaoModel>> {

  @override
  Future<List<TransacaoModel>> build() async {
    // Mantém os dados na memória mesmo se a tela for fechada
    final link = ref.keepAlive();

    final authState = ref.watch(authProvider);
    final mesAnoSelecionado = ref.watch(mesTransacaoSelecionadoProvider);

    if (!authState.isAuthenticated || mesAnoSelecionado == null) return [];

    // Se não tiver mês selecionado, NÃO BUSCA NADA
    // (obriga a UI a selecionar um mês válido)
    if (mesAnoSelecionado == null) {
      return [];
    }

    return _buscarTransacoes(authState.userId, mesAnoSelecionado);
  }

  Future<List<TransacaoModel>> _buscarTransacoes(
  String userId,
  String mesAno,
) async {

  final cache = await TransacaoCacheManager.buscarDoCache(mesAno);

  if (cache != null) {
    state = AsyncValue.data(cache); 
  }

  final List<TransacaoModel> transacoes = [];
  final dbRef = FirebaseDatabase.instance.ref("transacoes/$mesAno");

  final snapshot = await dbRef.get();
  if (!snapshot.exists) return [];

  final Map<dynamic, dynamic> nivelMes = snapshot.value as Map;

  for (final entry in nivelMes.entries) {
    final chave = entry.key;
    final valor = entry.value;

    if (valor is Map && valor.containsKey(userId)) {
  final String chaveData = chave;

  // Se a chave já for uma data completa (dd-MM-yyyy), usa direto
  // Caso contrário, monta usando dia + mesAno
  final String dataFinal = RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(chaveData)
      ? chaveData
      : '$chaveData-$mesAno';

  final Map<dynamic, dynamic> transacoesUsuario = valor[userId];

  for (final t in transacoesUsuario.entries) {
    final id = t.key;
    final dados = t.value;

    final mapCompleto = {
      ...dados,
      'idTransacao': id,
      'data': dataFinal,
    };

    transacoes.add(TransacaoModel.fromMap(mapCompleto));
  }
}

    //Estrutura SEM DIA → mes/user/transacao
    else if (chave == userId && valor is Map) {
      final Map<dynamic, dynamic> transacoesUsuario = valor;

      for (final t in transacoesUsuario.entries) {
        final id = t.key;
        final dados = t.value;

        final mapCompleto = {
          ...dados,
          'idTransacao': id,
          'data': '01-$mesAno',
        };

        transacoes.add(TransacaoModel.fromMap(mapCompleto));
      }
    }

  }

  // Ordenação segura
  transacoes.sort((a, b) {
    final da = DateFormat("dd-MM-yyyy").parse(a.data);
    final db = DateFormat("dd-MM-yyyy").parse(b.data);
    return db.compareTo(da);
  });

  await TransacaoCacheManager.salvarNoCache(mesAno, transacoes);

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

    //Lógica de salvar no Realtime DB
    final idTransacaoToUse = transacao.idTransacao.isNotEmpty ? transacao.idTransacao : DateTime.now().millisecondsSinceEpoch.toString();
    final dataAtual = DateTime.now();
    final mesAno = DateFormat("MM-yyyy").format(dataAtual); 
    final dia = DateFormat("dd").format(dataAtual); 

    
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
    ref.invalidate(mesesComTransacoesProvider);
  }

  // --- Lógica de Exclusão (Soft Delete) ---
  Future<void> excluirTransacao(TransacaoModel transacao) async {
    final userId = ref.read(authProvider).userId;
    if (userId.isEmpty) return;

    // Extrair data para encontrar o caminho no DB
    // Nota: O formato de data no seu model é dd-MM-yyyy
    final partesData = transacao.data.split('-');
    final dia = partesData[0];
    final mesAno = "${partesData[1]}-${partesData[2]}";

    final dbRef = FirebaseDatabase.instance
        .ref("transacoes")
        .child(mesAno)
        .child(dia)
        .child(userId)
        .child(transacao.idTransacao);

    // Calcular Estorno de Saldo
    final saldoModel = ref.read(saldoProvider);
    final saldoAtual = saldoModel.saldo;
    double novoSaldo;

    if (transacao.tipoTransacao == TipoTransacao.deposito) {
      // Se era entrada, ao excluir eu subtraio
      novoSaldo = saldoAtual - transacao.valor;
    } else {
      // Se era saída (pagamento/transferência), ao excluir eu devolvo o dinheiro
      novoSaldo = saldoAtual + transacao.valor;
    }

    // Atualizar status no DB (Soft Delete) e o Saldo
    await dbRef.update({'status': 'excluida'});
    
    final contaRef = FirebaseDatabase.instance.ref().child('contas').child(userId);
    await contaRef.update({'saldo': novoSaldo});

    // Notificar o sistema da mudança
    ref.invalidateSelf();
    ref.read(saldoProvider.notifier).atualizarSaldo(novoSaldo);
  }

  // --- Lógica de Edição com Histórico ---
  Future<void> editarTransacao({
    required TransacaoModel oldTransacao,
    required TransacaoModel newTransacao,
  }) async {
    final userId = ref.read(authProvider).userId;
    if (userId.isEmpty) return;

    final partesData = oldTransacao.data.split('-');
    final dia = partesData[0];
    final mesAno = "${partesData[1]}-${partesData[2]}";

    // Gerar registros de histórico comparando o que mudou
    List<TransacaoHistorico> novoHistorico = List.from(oldTransacao.historico);
    final dataModificacao = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    if (oldTransacao.valor != newTransacao.valor) {
      novoHistorico.add(TransacaoHistorico(
        campoModificado: 'valor',
        dataModificacao: dataModificacao,
        valorAnterior: oldTransacao.valor,
        valorAtualizado: newTransacao.valor,
      ));
    }

    if (oldTransacao.descricao != newTransacao.descricao) {
      novoHistorico.add(TransacaoHistorico(
        campoModificado: 'descricao',
        dataModificacao: dataModificacao,
        valorAnterior: oldTransacao.descricao,
        valorAtualizado: newTransacao.descricao,
      ));
    }

    // Calcular impacto no saldo
    // Lógica: Reverte o antigo e aplica o novo
    final saldoModel = ref.read(saldoProvider);
    final saldoAtual = saldoModel.saldo ?? 0;
    
    // Remove o efeito da transação antiga
    double saldoTemporario = (oldTransacao.tipoTransacao == TipoTransacao.deposito)
        ? saldoAtual - oldTransacao.valor
        : saldoAtual + oldTransacao.valor;

    // Aplica o efeito da nova transação
    double novoSaldoFinal = (newTransacao.tipoTransacao == TipoTransacao.deposito)
        ? saldoTemporario + newTransacao.valor
        : saldoTemporario - newTransacao.valor;

    // Preparar objeto final para salvar
    final transacaoFinal = newTransacao.copyWith(
      historico: novoHistorico,
      saldo: novoSaldoFinal,
      saldoAnterior: saldoAtual,
    );

    // Salvar no Realtime Database
    final dbRef = FirebaseDatabase.instance
        .ref("transacoes")
        .child(mesAno)
        .child(dia)
        .child(userId)
        .child(oldTransacao.idTransacao);

    await dbRef.set(transacaoFinal.toMap());

    // Atualizar saldo da conta
    final contaRef = FirebaseDatabase.instance.ref().child('contas').child(userId);
    await contaRef.update({'saldo': novoSaldoFinal});

    // Invalida para atualizar a UI
    ref.invalidateSelf();
    ref.read(saldoProvider.notifier).atualizarSaldo(novoSaldoFinal);
  }
}

final transacoesProvider = AsyncNotifierProvider<TransacoesNotifier, List<TransacaoModel>>(TransacoesNotifier.new);