class Transacao {
  final String tipo;
  final double valor;
  final String idconta;
  final double saldoAnterior;
  final double saldo;
  final DateTime data;
  final String hora;
  final String status;
  final String idTransacao;
  //final Array historico;
    //dataModificacao: string;
    //campoModificado: string;
    //valorAnterior: any;
    //valorAtualizado: any;
  Transacao({
    required this.tipo,
    required this.valor,
    required this.idconta,
    required this.saldoAnterior,
    required this.saldo,  
    required this.data,
    required this.hora,
    required this.status,
    required this.idTransacao,
    //required this.historico,
  });

  factory Transacao.fromMap(Map<dynamic, dynamic> map, String idTransacao) {
  return Transacao(
    tipo: map['tipo'] ?? '',
    valor: (map['valor'] != null) ? (map['valor'] as num).toDouble() : 0.0,
    idconta: map['idconta'] ?? '',
    saldoAnterior: (map['saldoAnterior'] != null) ? (map['saldoAnterior'] as num).toDouble() : 0.0,
    saldo: (map['saldo'] != null) ? (map['saldo'] as num).toDouble() : 0.0,
    data: (map['data'] != null)
        ? DateTime.fromMillisecondsSinceEpoch(map['data'] as int)
        : DateTime.now(),
    hora: map['hora'] ?? '',
    status: map['status'] ?? '',
    idTransacao: idTransacao,
  );
}
}