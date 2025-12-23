import 'package:bytebank/features/auth/data/presentation/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bytebank/shared/themes/theme.dart';

// Screens do app
import 'package:bytebank/features/saldo/presentation/screens/dashboard_screen.dart';

import 'package:bytebank/routes.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  await initializeDateFormatting('pt_BR', null);
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget { 
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    //Acessa o estado de autenticação do AuthProvider do Riverpod
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bytebank',
      theme: bytebankTheme,
      routes: routes,
      initialRoute: AppRoutes.login,
      
      //Lógica de navegação baseada no estado do Riverpod
      home: authState.isAuthenticated 
            ? const DashboardScreen()
            : const LoginScreen()
    );
  }
}