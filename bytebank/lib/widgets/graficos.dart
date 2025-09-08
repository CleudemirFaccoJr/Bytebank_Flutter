import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


//Widget responsável por Gráfico Evolução de Saldo 
class EvolucaoSaldoChart extends StatelessWidget {
  const EvolucaoSaldoChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0: return const Text("Jan");
                  case 1: return const Text("Fev");
                  case 2: return const Text("Mar");
                }
                return const Text("");
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blue,
            spots: const [
              FlSpot(0, 1000),
              FlSpot(1, 2500),
              FlSpot(2, 2000),
              FlSpot(3, 4000),
            ],
          )
        ],
      ),
    );
  }
}

//Widget responsável por Gráfico de Gastos por Categoria
class GastosPorCategoriaChart extends StatelessWidget {
  const GastosPorCategoriaChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, title: "Alimentação", color: Colors.orange),
          PieChartSectionData(value: 30, title: "Transporte", color: Colors.blue),
          PieChartSectionData(value: 20, title: "Lazer", color: Colors.purple),
          PieChartSectionData(value: 10, title: "Outros", color: Colors.grey),
        ],
      ),
    );
  }
}

//Widget responsável por Gráfico Fluxo de Caixa
class FluxoDeCaixaChart extends StatelessWidget {
  const FluxoDeCaixaChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() == 0) return const Text("Entradas");
                if (value.toInt() == 1) return const Text("Saídas");
                return const Text("");
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5000, color: Colors.green)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3000, color: Colors.red)]),
        ],
      ),
    );
  }
}



class Graficos extends StatelessWidget{
  const Graficos({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Fluxo de Caixa (Mensal)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: FluxoDeCaixaChart()),

        SizedBox(height: 24),
        Text("Evolução do Saldo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: EvolucaoSaldoChart()),

        SizedBox(height: 24),
        Text("Gastos por Categoria", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: GastosPorCategoriaChart()),
      ],
    );
   
  }
}