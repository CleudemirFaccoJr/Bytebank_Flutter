import 'package:bytebank/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Providers do app
import 'package:bytebank/providers/authprovider.dart';
import 'package:bytebank/providers/saldoprovider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';

//Screens do app
import 'package:bytebank/screens/dashboard_screen.dart';

//Importando Widgets do app
import 'package:bytebank/widgets/navigationbar.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SaldoProvider()),
        ChangeNotifierProvider(create: (_) => TransacoesProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bytebank',
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
