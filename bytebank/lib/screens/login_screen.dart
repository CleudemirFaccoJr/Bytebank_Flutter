import 'package:flutter/material.dart';

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
    } else {
       // Exibir um erro caso algum campo esteja vazio
      print("Por favor, preencha todos os campos.");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder()),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}