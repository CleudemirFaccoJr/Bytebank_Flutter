class SaldoModel {
  final double saldo;
  final double? saldoAnterior;

  SaldoModel({
    required this.saldo,
    this.saldoAnterior,
  });

  // Para converter do Firebase Realtime Database
  factory SaldoModel.fromMap(Map<dynamic, dynamic> map) {
    return SaldoModel(
      saldo: (map['saldo'] ?? 0).toDouble(),
      saldoAnterior: map['saldoAnterior'] != null
          ? (map['saldoAnterior']).toDouble()
          : null,
    );
  }

  // Para salvar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'saldo': saldo,
      if (saldoAnterior != null) 'saldoAnterior': saldoAnterior,
    };
  }

  // Criar uma cópia modificando valores
  SaldoModel copyWith({
    double? saldo,
    double? saldoAnterior,
  }) {
    return SaldoModel(
      saldo: saldo ?? this.saldo,
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
    );
  }
}
