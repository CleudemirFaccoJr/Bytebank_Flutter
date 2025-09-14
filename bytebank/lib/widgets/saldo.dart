import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/providers/saldoprovider.dart';

class SaldoWidget extends StatefulWidget {
  const SaldoWidget({super.key});

  @override
  State<SaldoWidget> createState() => _SaldoWidgetState();
}

class _SaldoWidgetState extends State<SaldoWidget> {
  @override
  void initState() {
    super.initState();
    // chama o provider para carregar o saldo automaticamente
    Future.microtask(() =>
        Provider.of<SaldoProvider>(context, listen: false).carregarSaldo());
  }

  @override
  Widget build(BuildContext context) {
    final saldoProvider = Provider.of<SaldoProvider>(context);

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

          // Exibe loading até carregar
          saldoProvider.saldo == null
              ? const CircularProgressIndicator()
              : Text(
                  "R\$ ${saldoProvider.saldo!.toStringAsFixed(2)}",
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
