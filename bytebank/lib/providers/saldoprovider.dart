import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';

class SaldoProvider with ChangeNotifier {
  double? _saldo;

  double? get saldo => _saldo;

  Future<void> carregarSaldo() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final value = snapshot.value;

      if (value is num) {
        _saldo = value.toDouble();
      } else if (value is Map) {
        final innerValue = value['saldo']; 
        if (innerValue is num) {
          _saldo = innerValue.toDouble();
        }
      }

      notifyListeners();
    }
  } catch (e) {
    debugPrint("Erro ao carregar saldo: $e");
  }
}
}