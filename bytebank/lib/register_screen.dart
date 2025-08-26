import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastre-se'),
      ),
      body: Padding(
        padding:  const EdgeInsets.all(16), 
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                //placeholder: 'Digite seu e-mail',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                //placeholder: 'Digite sua senha',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Cadastrar'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

void _register() async{
  try {
    await _auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = e.message ?? 'Erro desconhecido';
    });
  }
}

}