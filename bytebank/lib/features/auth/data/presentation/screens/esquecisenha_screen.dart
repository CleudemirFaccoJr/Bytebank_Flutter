import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EsquecisenhaScreen extends ConsumerStatefulWidget {
  const EsquecisenhaScreen({super.key});

  @override
  ConsumerState<EsquecisenhaScreen> createState() => _EsquecisenhaScreen();
}

class _EsquecisenhaScreen extends ConsumerState<EsquecisenhaScreen> {
  final _emailController = TextEditingController();

  void _redefinirSenha() {
    String email = _emailController.text; //

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, preencha todos os campos.'), //
      ));
    } else {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      showDialog( //
        context: context,
        builder: (context) => AlertDialog( 
          title: const Text('Redefinição de Senha'), 
          content: Text('Um link de redefinição de senha foi enviado para $email.'), 
          actions: [ 
            TextButton( 
              onPressed: () { 
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text('OK'), 
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding( 
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Redefinir Senha",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Campo E-mail
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
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