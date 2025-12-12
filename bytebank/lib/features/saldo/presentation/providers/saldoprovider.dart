import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/features/saldo/data/models/saldo.dart';

class SaldoProvider extends ChangeNotifier {
  Saldo _saldo = Saldo(saldo: 0.0);
  Saldo get saldo => _saldo;

  void atualizarSaldo(double novoSaldo) {
    _saldo = _saldo.copyWith(
      saldoAnterior: _saldo.saldo,
      saldo: novoSaldo,
    );
    notifyListeners();
  }

  void limparSaldo() {
    _saldo = Saldo(saldo: 0.0, saldoAnterior: 0.0);
    notifyListeners();
  }
}
