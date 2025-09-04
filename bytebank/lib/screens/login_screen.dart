import 'package:bytebank/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

void main() => runApp(LoginScreen());

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
  }


class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();  

  void _login(){
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      // Simulação de login, você pode fazer validação ou chamar uma API
      print('Email: $email');
      print('Senha: $password');
      // Aqui você pode redirecionar para outra tela
      print("Você foi autenticado");
    } else {
       // Exibir um erro caso algum campo esteja vazio
      print("Por favor, preencha todos os campos.");
    }
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove a faixa de debug
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Logo
                      Image.asset(
                        "../lib/assets/logo.png",
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
                                print("Esqueci minha senha");
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
                    ],
                  ),
                ),
              ),
            ),
        ),
    );
  }
}