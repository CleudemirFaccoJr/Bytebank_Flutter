import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

class EsquecisenhaScreen extends StatefulWidget {
  const EsquecisenhaScreen({super.key});

  @override
  _EsquecisenhaScreen createState() => _EsquecisenhaScreen();
}

class _EsquecisenhaScreen extends State<EsquecisenhaScreen> {
  final _emailController = TextEditingController();

  void _redefinirSenha() {
    String email = _emailController.text;

    if (email.isEmpty) {
      print("Por favor, preencha todos os campos.");
      // Aqui você pode usar um SnackBar ou AlertDialog
    } else {
      print('Email: $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    height: 60,
                  ),

                  const SizedBox(height: 16),

                  // Campo Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: AppColors.verdeClaro),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.verdeClaro,
                      ),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _emailController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: AppColors.verdeClaroHover),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.verdeClaroHover),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: AppColors.verdeClaroHover,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),


                  const SizedBox(height: 24),

                  // Botões lado a lado
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Voltar
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Cancelar"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _redefinirSenha,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdeClaro,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Redefinir Senha"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
