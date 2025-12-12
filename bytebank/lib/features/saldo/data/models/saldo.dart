class Saldo {
  final double saldo;
  final double? saldoAnterior;

  Saldo({
    required this.saldo,
    this.saldoAnterior,
  });

  // Para converter do Firebase Realtime Database
  factory Saldo.fromMap(Map<dynamic, dynamic> map) {
    return Saldo(
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
  Saldo copyWith({
    double? saldo,
    double? saldoAnterior,
  }) {
    return Saldo(
      saldo: saldo ?? this.saldo,
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
    );
  }
}
