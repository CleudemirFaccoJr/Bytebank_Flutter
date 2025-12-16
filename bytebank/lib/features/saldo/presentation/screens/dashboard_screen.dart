import 'package:bytebank/app_colors.dart';
import 'package:bytebank/features/auth/data/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Adiciona o Riverpod
import 'package:bytebank/features/transacoes/presentation/screens/transacoes_screen.dart';
import 'package:bytebank/features/transacoes/presentation/screens/extrato_screen.dart';
import 'package:bytebank/routes.dart';

//Importando Providers do Riverpod
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart'; // Já é Riverpod

//Importando Widgets do App
import 'package:bytebank/shared/widgets/navigationbar.dart';
import 'package:bytebank/shared/widgets/saldo.dart';
import 'package:bytebank/shared/widgets/acessorapido.dart';
import 'package:bytebank/shared/widgets/graficos.dart'; // O GraficosWidget refatorado é um ConsumerWidget

// Migra de StatefulWidget para ConsumerStatefulWidget para manter a variável currentPageIndex
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/home';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int currentPageIndex = 0;

  List<Widget> buildPages(BuildContext context) {
    return [
      SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SaldoWidget(), // Assuming SaldoWidget is a Riverpod ConsumerWidget

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
                            //body: const ExtratoScreen(),
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

            // Chama diretamente o Widget refatorado
            const GraficosWidget(), //
          ],
        ),
      ),

      //const ExtratoScreen(),

      const Center(child: Text("Investimentos")),

      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Acessa o AuthState usando o Riverpod e observa o nome do usuário
    final authState = ref.watch(authProvider); //
    final userName = authState.displayName; // Utiliza o getter displayName

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.corBytebank,

        automaticallyImplyLeading: false,

        title: Text("Olá - $userName", style: const TextStyle(color: Colors.white)),

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
                        // Acesso ao Notifier para chamar o logout
                        ref.read(authProvider.notifier).logout().catchError((e) {
                           // Lidar com erro de logout se necessário (authprovider pode relançar)
                        });
                        
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
      //TODO: Implementar FloatingActionButton corretamente
      // floatingActionButton: currentPageIndex == 0
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => TransacoesScreen()),
      //           );
      //         },
      //         backgroundColor: AppColors.corBytebank,
      //         foregroundColor: Colors.white,
      //         child: const Icon(Icons.add),
      //       )
      //     : null,

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