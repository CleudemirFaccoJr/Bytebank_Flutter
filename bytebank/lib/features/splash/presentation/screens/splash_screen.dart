import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart'; 

// Importa as telas de destino
import 'package:bytebank/features/saldo/presentation/screens/dashboard_screen.dart';
import 'package:bytebank/features/auth/data/presentation/screens/login_screen.dart';

// 1. Mudar para ConsumerStatefulWidget
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  // 2. Mudar a assinatura do createState para ConsumerState
  ConsumerState<SplashScreen> createState() => _SplashScreenState(); 
}

// 3. Mudar a classe de State para ConsumerState
class _SplashScreenState extends ConsumerState<SplashScreen> { 
  @override
  void initState() {
    super.initState();
    
    // Atrasamos a chamada para _checkAuthAndNavigate para garantir que 
    // o widget já tenha o context e o ref disponíveis.
    Future.microtask(() => _checkAuthAndNavigate());
  }

  void _checkAuthAndNavigate() async {
    // Adiciona um delay mínimo para o efeito visual da splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 4. Usar ref.read para obter o estado atual do AuthProvider (sem reconstruir)
    final authState = ref.read(authProvider);

    // 5. Verifica se o usuário está autenticado
    if (authState.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.corBytebank,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Verifique se o caminho da sua logo está correto!
            Image.asset(
              'assets/images/logo_bytebank.png', 
              width: 150, 
              height: 150,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}