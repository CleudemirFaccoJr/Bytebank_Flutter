import 'dart:io';

import 'package:bytebank/app_colors.dart';
import 'package:bytebank/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/screens/transacoes_screen.dart';
import 'package:bytebank/screens/extrato_screen.dart';

//Importando Providers
import 'package:provider/provider.dart';
import 'package:bytebank/providers/authprovider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';

//Importantdo Widgets do App
import 'package:bytebank/widgets/navigationbar.dart';
import 'package:bytebank/widgets/saldo.dart';
import 'package:bytebank/widgets/acessorapido.dart';
import 'package:bytebank/widgets/graficos.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _mesSelecionado =
      "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
  final List<String> _mesesDisponiveis = [
    "08-2025",
    "09-2025",
    "10-2025",
    // pode ser gerado dinamicamente depois
  ];

  int currentPageIndex = 0;

  List<Widget> buildPages(BuildContext context) {
    return [
      SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SaldoWidget(),

            const SizedBox(height: 16),

            AcessoRapidoWidget(
              onItemTap: (label) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ExtratoScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            //Gráficos
            Row(
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

                  items: _mesesDisponiveis.map((mes) {
                    return DropdownMenuItem(value: mes, child: Text(mes));
                  }).toList(),

                  onChanged: (novoMes) {
                    if (novoMes != null) {
                      setState(() {
                        _mesSelecionado = novoMes;
                      });

                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      Provider.of<TransacoesProvider>(
                        context,
                        listen: false,
                      ).buscarTransacoes(auth.userId, mesAno: novoMes);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            buildGraficos(context),
          ],
        ),
      ),

      ExtratoScreen(),

      Center(child: Text("Investimentos")),

      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final userName = authProvider.userName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.corBytebank,

        automaticallyImplyLeading: false,

        title: Text("Olá - $userName", style: TextStyle(color: Colors.white)),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),

            onPressed: () {
              showDialog(
                context: context,

                builder: (context) => AlertDialog(
                  title: const Text("Sair do App"),

                  content: const Text(
                    "Tem certeza que deseja sair do aplicativo?",
                  ),

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),

                      child: const Text("Cancelar"),

                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.verdeClaro,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        exit(0);
                      },

                      child: const Text("Sair"),

                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: buildPages(context)[currentPageIndex],

      floatingActionButton: currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransacoesScreen()),
                );
              },
              backgroundColor: AppColors.corBytebank,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      //Barra de Navegação Inferior
      bottomNavigationBar: Navigationbar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}
