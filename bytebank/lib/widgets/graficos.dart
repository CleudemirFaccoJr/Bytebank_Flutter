import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bytebank/providers/transacoesprovider.dart';
import 'package:bytebank/providers/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; 
import 'package:bytebank/app_colors.dart';

class GraficosWidget extends StatefulWidget {
  const GraficosWidget({super.key});

  @override
  State<GraficosWidget> createState() => _GraficosWidgetState();
}

class _GraficosWidgetState extends State<GraficosWidget> {
  // Inicializa com o mês atual no formato MM-yyyy (como salvo no Firebase)
  String _mesSelecionado = DateFormat('MM-yyyy').format(DateTime.now());
  List<String> _mesesDisponiveisKeys = [];

  @override
  void initState() {
    super.initState();
    _fetchMesesDisponiveis();
    // Inicia a primeira busca de transações para o mês atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarTransacoesParaMes(_mesSelecionado);
    });
  }

  // Método para buscar as chaves MM-yyyy no nó 'transacoes' do Firebase
  Future<void> _fetchMesesDisponiveis() async {
    final dbRef = FirebaseDatabase.instance.ref().child('transacoes');
    final snapshot = await dbRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final mesesMap = snapshot.value as Map;
      
      final List<String> availableKeys = mesesMap.keys
          .cast<String>()
          // Filtra chaves que parecem MM-yyyy
          .where((key) => RegExp(r'^\d{2}-\d{4}$').hasMatch(key))
          .toList();
      
      // Ordena do mais recente para o mais antigo
      availableKeys.sort((a, b) {
        final dateA = DateFormat('MM-yyyy').parse(a);
        final dateB = DateFormat('MM-yyyy').parse(b);
        return dateB.compareTo(dateA); 
      });

      setState(() {
        _mesesDisponiveisKeys = availableKeys;
        
        // Garante que o mês selecionado inicial seja o mais recente
        if (!_mesesDisponiveisKeys.contains(_mesSelecionado) && _mesesDisponiveisKeys.isNotEmpty) {
          _mesSelecionado = _mesesDisponiveisKeys.first;
          _buscarTransacoesParaMes(_mesSelecionado);
        }
      });
    }
  }
  
  // Função auxiliar para formatar MM-yyyy para Mês/yyyy (Ex: 09-2025 -> Setembro/2025)
  String _formatMesKey(String mesKey) {
    try {
      final date = DateFormat('MM-yyyy').parse(mesKey);
      return DateFormat('MMMM/yyyy', 'pt_BR').format(date);
    } catch (e) {
      return mesKey;
    }
  }
  
  // Função para chamar o provider para buscar as transações do mês selecionado
  void _buscarTransacoesParaMes(String mesAno) {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      if (auth.userId.isNotEmpty) {
          Provider.of<TransacoesProvider>(
            context,
            listen: false,
          ).buscarTransacoes(auth.userId, mesAno: mesAno);
      }
  }

  // Novo método para construir o Dropdown e o título
  Widget _buildDropdownRow(BuildContext context) {
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
                  value: _mesSelecionado,
                  hint: const Text('Selecione o Mês'),
                  items: _mesesDisponiveisKeys.map((mesKey) {
                      return DropdownMenuItem(
                          value: mesKey, 
                          child: Text(_formatMesKey(mesKey)), 
                      );
                  }).toList(),
                  onChanged: (novoMesKey) {
                      if (novoMesKey != null) {
                          setState(() {
                              _mesSelecionado = novoMesKey;
                          });
                          _buscarTransacoesParaMes(novoMesKey);
                      }
                  },
              ),
          ],
      );
  }


  @override
  Widget build(BuildContext context) {
    final transacoesProvider = Provider.of<TransacoesProvider>(context);
    final transacoes = transacoesProvider.transacoes;

    // Definição das cores para o gráfico de pizza
    final coresCategorias = [
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.teal,
        Colors.brown,
        Colors.indigo,
    ];

    if (transacoes.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownRow(context),
            const SizedBox(height: 16),
            const Text("Nenhuma transação encontrada para o mês selecionado."),
          ],
        );
    }
    
    // Cálculo do total de entradas e saídas
    final totalEntradas = transacoes
        .where((t) => t.tipo == "deposito")
        .fold(0.0, (sum, t) => sum + t.valor);

    final totalSaidas = transacoes
        .where((t) => t.tipo == "saida" || t.tipo == "transferencia" || t.tipo == "pagamento")
        .fold(0.0, (sum, t) => sum + t.valor);

    // Evolução do saldo (depósitos acumulados)
    final depositos = transacoes.where((t) => t.tipo == "deposito").toList()
    ..sort((a, b) => a.data.compareTo(b.data));

    double acumulado = 0;
    final pontosSaldo = depositos.map((t) {
    acumulado += t.valor;
      
      // ⚠️ LINHA QUE ESTAVA DANDO ERRO: t.data.day.toDouble()
      // CORREÇÃO: Converte a String ('dd-MM-yyyy') para DateTime.
      final date = DateFormat('dd-MM-yyyy').parse(t.data);
      
      // Agora você pode acessar o 'day' do objeto DateTime.
  return FlSpot(date.day.toDouble(), acumulado);
      
  }).toList();


    // Gastos por categoria
    final Map<String, double> gastosPorCategoria = {};
    for (var t in transacoes.where((t) => t.tipo == "transferencia" || t.tipo == "saida" || t.tipo == "pagamento")) {
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
        // O novo widget com o título e o Dropdown
        _buildDropdownRow(context),

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
                  spots: pontosSaldo.isNotEmpty ? pontosSaldo : [FlSpot(0, 0)],
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
}

// A função buildGraficos agora apenas retorna o novo StatefulWidget
Widget buildGraficos(BuildContext context) {
  return const GraficosWidget();
}