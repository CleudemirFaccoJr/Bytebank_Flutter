import 'transacao_historicomodel.dart';

class TransacaoModel {
  final String idTransacao;
  final String categoria;
  final String data;
  final String descricao;
  final String hora;
  final int saldo;
  final int saldoAnterior;
  final String status;
  final String tipoTransacao;
  final int valor;
  final List<TransacaoHistorico> historico;
  final String anexoUrl;
  final String? checksum;

  TransacaoModel({
    required this.idTransacao,
    required this.categoria,
    required this.data,
    required this.descricao,
    required this.hora,
    required this.saldo,
    required this.saldoAnterior,
    required this.status,
    required this.tipoTransacao,
    required this.valor,
    required this.historico,
    required this.anexoUrl,
    this.checksum,
  });

  factory TransacaoModel.fromMap(Map<dynamic, dynamic> map) {
    return TransacaoModel(
      idTransacao: map['idTransacao'],
      categoria: map['categoria'],
      data: map['data'],
      descricao: map['descricao'],
      hora: map['hora'],
      saldo: map['saldo'],
      saldoAnterior: map['saldoAnterior'],
      status: map['status'],
      tipoTransacao: map['tipoTransacao'],
      valor: map['valor'],
      anexoUrl: map['anexoUrl'] ?? '',
      checksum: map['checksum'],
      historico: map['historico'] != null
          ? (map['historico'] as List)
              .map((item) => TransacaoHistorico.fromMap(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTransacao': idTransacao,
      'categoria': categoria,
      'data': data,
      'descricao': descricao,
      'hora': hora,
      'saldo': saldo,
      'saldoAnterior': saldoAnterior,
      'status': status,
      'tipoTransacao': tipoTransacao,
      'valor': valor,
      'anexoUrl': anexoUrl,
      'checksum': checksum,
      'historico': historico.map((h) => h.toMap()).toList(),
    };
  }
}
