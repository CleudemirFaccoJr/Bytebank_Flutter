import 'package:bytebank/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bytebank/screens/esquecisenha_screen.dart';
import 'package:bytebank/screens/register_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LoginScreen());
} 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
  }


class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();  

  Future<void> _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Por favor, preencha todos os campos"),
        backgroundColor: Colors.red,
      ),
    );
    print("Campos vazios!");
    return;
  }

  try {
    // A chamada assíncrona para o Firebase ocorre aqui
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("Login bem-sucedido!");
    // Verifique se o widget ainda está montado antes de usar o 'context'
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você está logado!"),
          backgroundColor: AppColors.verdeClaro,
        ),
      );

      // E navegue para a tela do dashboard
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage = "Verifique os dados digitados.";

    if (e.code == 'user-not-found') {
      errorMessage = "Usuário não encontrado.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Senha incorreta.";
    } else if (e.code == 'invalid-email') {
      errorMessage = "Formato de e-mail inválido.";
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
    print("Erro de autenticação: ${e.code}");
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro inesperado: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    print("Erro inesperado: $e");
  }
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Logo
                      Image.asset(
                        "assets/logo.png",
                        height: 60,
                      ),
                      const SizedBox(height: 16,),

                      //Campo Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: AppColors.verdeClaro),
                          prefixIcon: const Icon(Icons.email, color: AppColors.verdeClaro,),
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
                          borderSide: const BorderSide(color: AppColors.verdeClaroHover, width: 2),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      //Campo Senha
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: const TextStyle(color: AppColors.verdeClaro),
                          prefixIcon: const Icon(Icons.lock, color: AppColors.verdeClaro),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: AppColors.corBytebank),
                          ),
                           enabledBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(6),
                           borderSide: const BorderSide(color: AppColors.verdeClaroHover),
                        ),
                          focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.verdeClaroHover, width: 2),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16,),

                    // Esqueci minha senha
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EsquecisenhaScreen(),
                                ),
                              );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "Esqueci minha senha",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          //Botão Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.corBytebank,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                                )
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                          ),

                          const SizedBox(height: 16),

                         // Botão de Cadastre-se
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.corBytebank,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Abrir minha Conta',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  ]
                  )
                  )
              )
          )
    );
  }
}