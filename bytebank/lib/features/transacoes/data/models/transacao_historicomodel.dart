class TransacaoHistorico {
  final String campoModificado;
  final String dataModificacao;
  final dynamic valorAnterior;
  final dynamic valorAtualizado;
  final String? tipoTransacaoAnterior;
  final String? tipoTransacaoAtualizado;

  TransacaoHistorico({
    required this.campoModificado,
    required this.dataModificacao,
    required this.valorAnterior,
    required this.valorAtualizado,
    this.tipoTransacaoAnterior,
    this.tipoTransacaoAtualizado,
  });

  factory TransacaoHistorico.fromMap(Map<dynamic, dynamic> map) {
    return TransacaoHistorico(
      campoModificado: map['campoModificado'],
      dataModificacao: map['dataModificacao'],
      valorAnterior: map['valorAnterior'],
      valorAtualizado: map['valorAtualizado'],
      tipoTransacaoAnterior: map['tipoTransacaoAnterior'],
      tipoTransacaoAtualizado: map['tipoTransacaoAtualizado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campoModificado': campoModificado,
      'dataModificacao': dataModificacao,
      'valorAnterior': valorAnterior,
      'valorAtualizado': valorAtualizado,
      'tipoTransacaoAnterior': tipoTransacaoAnterior,
      'tipoTransacaoAtualizado': tipoTransacaoAtualizado,
    };
  }
}
