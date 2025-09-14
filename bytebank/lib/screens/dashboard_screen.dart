import 'dart:io';

import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/widgets/navigationbar.dart';
import 'package:bytebank/widgets/saldo.dart';
import 'package:bytebank/widgets/acessorapido.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/providers/saldoprovider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPageIndex = 0;

  final List<Widget> pages = [
    Center(child: Text("Início")),
    Center(child: Text("Transações")),
    Center(child: Text("Investimentos")),
    Center(child: Text("Perfil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.corBytebank,
        automaticallyImplyLeading: false,
        title: const Text("Bytebank",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
             showDialog(
              context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Sair do App"),
                content: const Text("Tem certeza que deseja sair do aplicativo?"),
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              )
              );
            },
          ),
        ],
      ),

          

      body: RefreshIndicator(
        
        onRefresh: () async {
          await Provider.of<SaldoProvider>(context, listen: false).carregarSaldo();
        },
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // 👈 necessário pro pull funcionar mesmo sem scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaldoWidget(),
            const SizedBox(height: 16),
            AcessoRapidoWidget(),
            const SizedBox(height: 16),
            Text(
              'Gráficos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.verdeClaro,
              ),
            ),
            const SizedBox(height: 8),
            
          ],
        ),
      ),
      ),

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
