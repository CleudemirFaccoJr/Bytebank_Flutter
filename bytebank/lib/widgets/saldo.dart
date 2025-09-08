import 'package:flutter/material.dart';

class SaldoWidget extends StatelessWidget {
  final double saldo;

  const SaldoWidget({
    super.key,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC8F6CD), // Cor de fundo do seu design
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}