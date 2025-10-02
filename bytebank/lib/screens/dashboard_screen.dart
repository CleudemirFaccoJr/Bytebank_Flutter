import 'dart:io';

import 'package:bytebank/app_colors.dart';
import 'package:bytebank/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/screens/transacoes_screen.dart';
import 'package:bytebank/screens/extrato_screen.dart';
import 'package:bytebank/routes.dart';

//Importando Providers
import 'package:provider/provider.dart';
import 'package:bytebank/providers/authprovider.dart';

//Importantdo Widgets do App
import 'package:bytebank/widgets/navigationbar.dart';
import 'package:bytebank/widgets/saldo.dart';
import 'package:bytebank/widgets/acessorapido.dart';
import 'package:bytebank/widgets/graficos.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/home';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
                if (label == 'Extrato') {
                  // Verifica se é o item Extrato
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          Scaffold(
                            appBar: AppBar(
                              title: const Text("Extrato de Transações"),
                              backgroundColor: AppColors.corBytebank,
                              foregroundColor: Colors.white,
                            ),
                            body: const ExtratoScreen(),
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // entra da direita
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end);
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            );

                            return SlideTransition(
                              position: tween.animate(curvedAnimation),
                              child: child,
                            );
                          },
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

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
                        Navigator.of(context).pop();
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
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
