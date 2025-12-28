import 'package:bytebank/features/transacoes/data/models/transacao_historicomodel.dart';

enum TipoTransacao {
  deposito,
  transferencia,
  pagamento,
  investimento;

  String get label {
    switch (this) {
      case TipoTransacao.deposito: return 'Depósito';
      case TipoTransacao.transferencia: return 'Transferência';
      case TipoTransacao.pagamento: return 'Pagamento';
      case TipoTransacao.investimento: return 'Investimento';
    }
  }
}

enum CategoriaTransacao {
  saude,
  lazer,
  investimento,
  transporte,
  alimentacao,
  outros;

  String get label {
    switch (this) {
      case CategoriaTransacao.saude: return 'Saúde';
      case CategoriaTransacao.lazer: return 'Lazer';
      case CategoriaTransacao.investimento: return 'Investimento';
      case CategoriaTransacao.transporte: return 'Transporte';
      case CategoriaTransacao.alimentacao: return 'Alimentação';
      case CategoriaTransacao.outros: return 'Outros';
    }
  }
}

class TransacaoModel {
  final String idTransacao;
  final CategoriaTransacao categoria;
  final String data;
  final String descricao;
  final String hora;
  final double saldo;
  final double saldoAnterior;
  final String status;
  final TipoTransacao tipoTransacao;
  final double valor;
  final List<dynamic> historico;
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

  // Converte de Objeto para Map (Para o Firebase)
  Map<String, dynamic> toMap() {
    return {
      'idTransacao': idTransacao,
      'categoria': categoria.name,
      'data': data,
      'descricao': descricao,
      'hora': hora,
      'saldo': saldo,
      'saldoAnterior': saldoAnterior,
      'status': status,
      'tipoTransacao': tipoTransacao.name,
      'valor': valor,
      'anexoUrl': anexoUrl,
      'checksum': checksum,
      'historico': historico,
    };
  }

  // Converte de Map para Objeto (Lendo do Firebase)
  factory TransacaoModel.fromMap(Map<dynamic, dynamic> map) {
  return TransacaoModel(
    idTransacao: map['idTransacao'] ?? '', // Proteção contra nulo
    categoria: CategoriaTransacao.values.firstWhere(
      (e) => e.name == map['categoria'],
      orElse: () => CategoriaTransacao.outros,
    ),
    data: map['data'] ?? '', // Proteção contra nulo
    descricao: map['descricao'] ?? '', // Proteção contra nulo
    hora: map['hora'] ?? '', // Proteção contra nulo
    saldo: (map['saldo'] as num?)?.toDouble() ?? 0.0,
    saldoAnterior: (map['saldoAnterior'] as num?)?.toDouble() ?? 0.0,
    status: map['status'] ?? 'ativa', // Proteção contra nulo
    tipoTransacao: TipoTransacao.values.firstWhere(
      (e) => e.name == map['tipoTransacao'],
      orElse: () => TipoTransacao.pagamento,
    ),
    valor: (map['valor'] as num?)?.toDouble() ?? 0.0, // Adicionado o ? e o ?? 0.0
    anexoUrl: map['anexoUrl'] ?? '',
    checksum: map['checksum'],
    historico: map['historico'] ?? [],
  );
}

  TransacaoModel copyWith({
    CategoriaTransacao? categoria,
    String? data,
    String? descricao,
    String? hora,
    double? saldo,
    double? saldoAnterior,
    String? status,
    TipoTransacao? tipoTransacao,
    double? valor,
    List<TransacaoHistorico>? historico,
    String? anexoUrl,
    String? checksum,
  }) {
    return TransacaoModel(
      idTransacao: idTransacao,
      categoria: categoria ?? this.categoria,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      hora: hora ?? this.hora,
      saldo: saldo ?? this.saldo,
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
      status: status ?? this.status,
      tipoTransacao: tipoTransacao ?? this.tipoTransacao,
      valor: valor ?? this.valor,
      historico: historico ?? this.historico,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      checksum: checksum ?? this.checksum,
    );
  }
}