import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/widgets/navigationbar.dart';
import 'package:bytebank/widgets/graficos.dart';
import 'package:bytebank/widgets/saldo.dart';

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
        title: const Text("Bytebank",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaldoWidget(saldo: 3922.59),
          ],
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
