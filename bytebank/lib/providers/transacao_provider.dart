import 'package:flutter/material.dart';

class TransacaoProvider with ChangeNotifier {
  double _saldo = 3922.60;
  double get saldo => _saldo;

  void adicionar(double valor) {
    _saldo += valor;
    notifyListeners();
  }

  void remover(double valor) {
    _saldo -= valor;
    notifyListeners();
  }
}
