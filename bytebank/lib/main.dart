import 'package:flutter/material.dart';
import 'package:bytebank/routes.dart';
import 'package:bytebank/register_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bytebank',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.register,
      routes: {
        Routes.register: (context) => const RegisterScreen(),
      },
    );
  }
}
