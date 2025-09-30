import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';

class SaldoProvider with ChangeNotifier {
  double? _saldo;

  double get saldo => _saldo ?? 0.0;

  Future<void> ajustarSaldoAposEdicao(
    BuildContext context, 
    double valorOriginal, 
    String tipoOriginal, 
    double novoValor, 
    String novoTipo
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");

    double novoSaldo = _saldo ?? 0.0;
    
    // 1. Reverter o impacto da transação original
    // Crédito original (soma)
    if (tipoOriginal == 'deposito' || tipoOriginal == 'investimento') {
      novoSaldo -= valorOriginal;
    } else { // Débito original (subtrai)
      novoSaldo += valorOriginal;
    }

    // 2. Aplicar o novo impacto da transação
    // Novo Crédito (soma)
    if (novoTipo == 'deposito' || novoTipo == 'investimento') {
      novoSaldo += novoValor;
    } else { // Novo Débito (subtrai)
      novoSaldo -= novoValor;
    }

    try {
      await ref.set(novoSaldo);
      _saldo = novoSaldo;
      notifyListeners();
      
      // Atualiza a lista de transações para refletir as mudanças
      await Provider.of<TransacoesProvider>(context, listen: false).buscarTransacoes(user.uid);
      
    } catch (e) {
      debugPrint("Erro ao ajustar saldo após edição: $e");
      rethrow;
    }
  }

  Future<void> atualizarSaldo(BuildContext context, double valor, String tipoTransacao) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");

    double novoSaldo = _saldo ?? 0.0;
    
    // Determina se a transação é um crédito (soma) ou débito (subtrai)
    if (tipoTransacao == 'deposito' || tipoTransacao == 'investimento') {
      novoSaldo += valor;
    } else { // Transferência, Pagamento, etc.
      novoSaldo -= valor;
    }

    try {
      await ref.set(novoSaldo);
      _saldo = novoSaldo;
      notifyListeners();
      
      // Agora o context está disponível e o erro desaparece
      // Certifique-se de que TransacoesProvider foi definido mais acima na árvore
      await Provider.of<TransacoesProvider>(context, listen: false).buscarTransacoes(user.uid);
      
    } catch (e) {
      debugPrint("Erro ao atualizar saldo: $e");
      rethrow;
    }
  }

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
      }else {
        _saldo = 0.0;
      }

      notifyListeners();
    }
  } catch (e) {
    debugPrint("Erro ao carregar saldo: $e");
  }
}
}