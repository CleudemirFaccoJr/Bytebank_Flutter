import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Transacao {
  final String idTransacao;
  final double valor;
  final String tipoTransacao;
  final String categoria;
  final DateTime data;
  final String descricao; 
  final String anexoUrl;
  final String hora;


  Transacao({
    required this.idTransacao,
    required this.valor,
    required this.tipoTransacao,
    required this.categoria,
    required this.data,
    required this.descricao,
    this.anexoUrl = '',
    this.hora = '',
  });

  factory Transacao.fromMap(String id, Map<dynamic, dynamic> map) {
    return Transacao(
      idTransacao: id,
      valor: (map['valor'] as num).toDouble(),
      tipoTransacao: map['tipoTransacao'] ?? '',
      categoria: map['categoria'] ?? '',
      data: DateFormat("dd-MM-yyyy").parse(map['data']),
      descricao: map['descricao'] ?? '',
      anexoUrl: map['anexoUrl'] ?? '',
      hora: map['hora'] ?? '',

    );
  }
} 

class TransacoesProvider with ChangeNotifier {
  List<Transacao> _transacoes = [];
  List<Transacao> get transacoes => _transacoes;

  // Adicionando uma nova variável para armazenar os meses
  List<String> _mesesComTransacoes = [];
  List<String> get mesesComTransacoes => _mesesComTransacoes;


  Future<void> buscarTransacoes(String userId, {String? mesAno}) async {
  _transacoes.clear();

  final dbRef = FirebaseDatabase.instance.ref("transacoes");

  final mesAtual = mesAno ??
      "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";

  // Acessa o nó do mês
  final snapshot = await dbRef.child(mesAtual).get();

  if (snapshot.exists) {
    debugPrint("Transações encontradas para $mesAtual");

    final Map<dynamic, dynamic>? dadosDoMes = snapshot.value as Map?;
    if (dadosDoMes != null) {
      
      // Itera sobre cada dia dentro do mês
      dadosDoMes.forEach((dia, dadosDoDia) {
        
        // Verifica se o userId existe dentro do nó do dia
        if (dadosDoDia is Map && dadosDoDia.containsKey(userId)) {
          final Map<dynamic, dynamic> transacoesMap = dadosDoDia[userId];
          
          transacoesMap.forEach((id, dadosDaTransacao) {
            _transacoes.add(Transacao.fromMap(id, dadosDaTransacao));
          });
        }
      });
      
      if (_transacoes.isNotEmpty) {
        debugPrint("Total de transações carregadas: ${_transacoes.length}");
        // Listando cada transação no console para depuração
        for (var t in _transacoes) {
          debugPrint("ID: ${t.idTransacao}, Tipo: ${t.tipoTransacao}, Valor: ${t.valor}, Data: ${t.data}, Categoria: ${t.categoria}");
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

  // **Novo método para carregar os meses com transações**
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
}
