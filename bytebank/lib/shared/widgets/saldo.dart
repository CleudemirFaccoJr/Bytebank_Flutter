import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:bytebank/features/saldo/presentation/providers/saldoprovider.dart';
import 'package:bytebank/features/saldo/data/models/saldomodel.dart'; 

class SaldoWidget extends ConsumerStatefulWidget {
  const SaldoWidget({super.key});

  @override
  ConsumerState<SaldoWidget> createState() => _SaldoWidgetState();
}

class _SaldoWidgetState extends ConsumerState<SaldoWidget> {
  @override
  void initState() {
    super.initState();
    //TODO: Substituir por chamada real de carregamento de saldo
    Future.microtask(() =>
        ref.read(saldoProvider.notifier).carregarSaldo(SaldoModel(saldo: 1500.75))
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldoModel = ref.watch(saldoProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC8F6CD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saldo disponível",
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "R\$ ${saldoModel.saldo.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}