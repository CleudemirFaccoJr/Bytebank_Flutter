import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/saldo/data/models/saldomodel.dart';

//Definir o Notifier
class SaldoNotifier extends Notifier<SaldoModel> {
  // O estado inicial do saldo é fornecido no build
  @override
  SaldoModel build() {
    return SaldoModel(saldo: 0.0);
  }

  void atualizarSaldo(double novoSaldo) {
    state = state.copyWith(
      saldoAnterior: state.saldo,
      saldo: novoSaldo,
    );
  }

  void limparSaldo() {
    state = SaldoModel(saldo: 0.0, saldoAnterior: 0.0);
  }

  void carregarSaldo(SaldoModel saldoCarregado) {
    state = saldoCarregado;
  }
}

//Definir o Provider global
final saldoProvider = NotifierProvider<SaldoNotifier, SaldoModel>(SaldoNotifier.new);