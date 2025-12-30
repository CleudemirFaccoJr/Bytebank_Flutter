import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:bytebank/features/transacoes/presentation/providers/transacoesprovider.dart';
import 'package:bytebank/app_colors.dart';

class GraficosWidget extends ConsumerWidget {
  const GraficosWidget({super.key});

  // Formata MM-yyyy → Mês/yyyy
  String _formatMesKey(String mesKey) {
    try {
      final date = DateFormat('MM-yyyy').parse(mesKey);
      return DateFormat('MMMM/yyyy', 'pt_BR').format(date);
    } catch (_) {
      return mesKey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providers observados
    final mesesDisponiveis = ref.watch(mesesComTransacoesProvider);
    final mesSelecionado = ref.watch(mesTransacaoSelecionadoProvider);
    final transacoesAsync = ref.watch(transacoesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          mesesDisponiveis: mesesDisponiveis,
          mesSelecionado: mesSelecionado,
          formatMes: _formatMesKey,
        ),
        const SizedBox(height: 16),

        transacoesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro ao carregar gráficos: $e'),
          data: (transacoes) {
            if (transacoes.isEmpty) {
              return const Text(
                'Nenhuma transação encontrada para o mês selecionado.',
                style: TextStyle(color: AppColors.cinzaCardTexto),
              );
            }

            return _GraficosBody(transacoes: transacoes);
          },
        ),
      ],
    );
  }
}

class _GraficosBody extends StatelessWidget {
  final List<TransacaoModel> transacoes;

  const _GraficosBody({required this.transacoes});

  @override
  Widget build(BuildContext context) {
    final coresCategorias = [
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
    ];

    final totalEntradas = transacoes
    .where((t) => t.tipoTransacao == TipoTransacao.deposito)
    .fold<double>(0, (sum, t) => sum + t.valor);

final totalSaidas = transacoes
    .where((t) => t.tipoTransacao != TipoTransacao.deposito)
    .fold<double>(0, (sum, t) => sum + t.valor);

    final transacoesOrdenadas = List<TransacaoModel>.from(transacoes)
      ..sort((a, b) {
         DateTime da = DateFormat("dd-MM-yyyy").parse(a.data);
         DateTime db = DateFormat("dd-MM-yyyy").parse(b.data);
         return da.compareTo(db);
      });

    double saldoAcumulado = 0;
    final pontosSaldo = <FlSpot>[];

    for (int i = 0; i < transacoesOrdenadas.length; i++) {
      final t = transacoesOrdenadas[i];

      if (t.tipoTransacao == TipoTransacao.deposito) {
        saldoAcumulado += t.valor;
      } else {
        saldoAcumulado -= t.valor;
      }

      pontosSaldo.add(
        FlSpot(i.toDouble(), saldoAcumulado),
      );
    }

    //Gastos por Categoria (apenas saídas)
    final Map<String, double> gastosPorCategoria = {};
    for (var t in transacoes.where((t) => t.tipoTransacao != TipoTransacao.deposito)) {
      final categoria = t.categoria.label;
      gastosPorCategoria[categoria] = (gastosPorCategoria[categoria] ?? 0) + t.valor;
    }

    final pieSections = gastosPorCategoria.entries.map((entry) {
  final index = gastosPorCategoria.keys.toList().indexOf(entry.key);
  final color = coresCategorias[index % coresCategorias.length];
  return PieChartSectionData(
    value: entry.value,
    title: "R\$ ${entry.value.toStringAsFixed(0)}",
    color: color,
    radius: 60,
    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
  );
}).toList();
    
    Widget legend(Color color, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Fluxo de Caixa",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: totalEntradas, color: Colors.green),
                  BarChartRodData(toY: totalSaidas, color: Colors.red),
                ])
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            legend(Colors.green, "Entradas"),
            const SizedBox(width: 16),
            legend(Colors.red, "Saídas"),
          ],
        ),

        const SizedBox(height: 24),
        Text("Evolução do Saldo",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blue,
                  spots: pontosSaldo.isNotEmpty
                      ? pontosSaldo
                      : [const FlSpot(0, 0)],
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text("Gastos por Categoria",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
        SizedBox(
          height: 200,
          child: PieChart(PieChartData(sections: pieSections)),
        ),
        Wrap(
          spacing: 12,
          children: gastosPorCategoria.entries.toList().asMap().entries.map(
            (entry) {
              final color =
                  coresCategorias[entry.key % coresCategorias.length];
              return legend(color, entry.value.key);
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  final List<String> mesesDisponiveis;
  final String? mesSelecionado;
  final String Function(String) formatMes;

  const _Header({
    required this.mesesDisponiveis,
    required this.mesSelecionado,
    required this.formatMes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Gráficos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.verdeClaro,
          ),
        ),
        DropdownButton<String>(
          value: mesSelecionado,
          hint: const Text('Selecione o Mês', style: TextStyle(color: Colors.black),),
          
          items: mesesDisponiveis
              .map(
                (mes) => DropdownMenuItem(
                  value: mes,
                  child: Text(formatMes(mes)),
                  
                ),
              )
              .toList(),
          onChanged: (novoMes) {
            if (novoMes != null) {
              ref.read(mesTransacaoSelecionadoProvider.notifier).state =
                  novoMes;
            }
          },
        ),
      ],
    );
  }
}
