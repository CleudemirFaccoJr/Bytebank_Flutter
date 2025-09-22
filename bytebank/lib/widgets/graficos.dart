import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bytebank/providers/transacoesprovider.dart';
import 'package:provider/provider.dart';

Widget buildGraficos(BuildContext context) {
  final transacoesProvider = Provider.of<TransacoesProvider>(context);
  final transacoes = transacoesProvider.transacoes;

  if (transacoes.isEmpty) {
    return const Text("Nenhuma transação encontrada");
  }

  // Definição das cores para o gráfico de pizza
  final coresCategorias = [
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
  ];

  // Fluxo de Caixa (entradas x saídas)
  final totalEntradas = transacoes
      .where((t) => t.tipoTransacao == "deposito")
      .fold(0.0, (sum, t) => sum + t.valor);

  final totalSaidas = transacoes
      .where((t) => t.tipoTransacao == "saida" || t.tipoTransacao == "transferencia" || t.tipoTransacao == "pagamento")
      .fold(0.0, (sum, t) => sum + t.valor);

  // Evolução do saldo (depósitos acumulados)
  final depositos = transacoes.where((t) => t.tipoTransacao == "deposito").toList()
    ..sort((a, b) => a.data.compareTo(b.data));

  double acumulado = 0;
  final pontosSaldo = depositos.map((t) {
    acumulado += t.valor;
    return FlSpot(t.data.day.toDouble(), acumulado);
  }).toList();

  // Gastos por categoria
  final Map<String, double> gastosPorCategoria = {};
  for (var t in transacoes.where((t) => t.tipoTransacao == "transferencia" || t.tipoTransacao == "saida" || t.tipoTransacao == "pagamento")) {
    gastosPorCategoria[t.categoria] =
        (gastosPorCategoria[t.categoria] ?? 0) + t.valor;
  }

  // Seções do gráfico de pizza com cores
  final pieSections = gastosPorCategoria.entries.toList().asMap().entries.map((entry) {
    int index = entry.key;
    MapEntry e = entry.value;
    final color = coresCategorias[index % coresCategorias.length];
    return PieChartSectionData(
      value: e.value,
      title: '${e.value.toStringAsFixed(2)}',
      color: color,
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }).toList();

  // Função para construir os itens da legenda
  Widget buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text("Fluxo de Caixa", style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      
      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(toY: totalEntradas, color: Colors.green),
                  BarChartRodData(toY: totalSaidas, color: Colors.red),
                ],
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (_, _) => const Text("Entradas / Saídas"),
                ),
              ),
            ),
          ),
        ),
      ),
      //Legenda do Fluxo de Caixa
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildLegendItem(Colors.green, "Entradas"),
          const SizedBox(width: 16),
          buildLegendItem(Colors.red, "Saídas"),
        ],
      ),

      const SizedBox(height: 24),
      Text("Evolução do Saldo", style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.blue,
                spots: pontosSaldo,
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
            ),
          ),
        ),
      ),
      buildLegendItem(Colors.blue, "Saldo Acumulado"),

      const SizedBox(height: 24),
      Text("Gastos por Categoria", style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: pieSections,
          ),
        ),
      ),
      Wrap(
        spacing: 16,
        runSpacing: 8,
        children: gastosPorCategoria.entries.toList().asMap().entries.map((entry) {
          int index = entry.key;
          MapEntry e = entry.value;
          final color = coresCategorias[index % coresCategorias.length];
          return buildLegendItem(color, e.key);
        }).toList(),
      ),
    ],
  );
}