import 'package:bytebank/app_colors.dart';
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
  final TextEditingController _nomeController = TextEditingController();
  bool _PoliticasdePrivacidade = false;
  String _errorMessage = '';

  void _register() async{
    if (!_PoliticasdePrivacidade){
      setState(() {
        _errorMessage = 
        "Você precisa aceitar a política de privacidade para continuar.";
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text
        );
    }on FirebaseAuthException catch (e){
      setState(() {
        _errorMessage = 
        e.message ?? "Erro Desconhecido";
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.corBytebank),
      prefixIcon: Icon(icon, color: AppColors.cinzaCardTexto),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crie sua conta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.corBytebank,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: const Icon(Icons.arrow_back, color: Colors.white),),
      ),

      //Body do Widget - Conteudo
      body: Padding(
        padding:  const EdgeInsets.all(16), 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

            Image.asset(
                        "../lib/assets/abriConta.png",
                        height: 160,
                      ),

            const SizedBox(height: 16),

            const Text(
              "Preencha os campos abaixo para criar a sua conta corrente!",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 16),

            //Campo Nome
            TextField(
              controller: _nomeController,
              decoration: _inputDecoration(
                "Nome", Icons.person
                //placeholder: 'Digite seu nome',
              ),
            ),

            const SizedBox(height: 16),

            //Campo Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration("Email", Icons.email),
            ),

            const SizedBox(height: 16),

            //Campo Senha
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("Senha", Icons.lock),
            ),

          const SizedBox(height: 20),

            // Checkbox de política
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _PoliticasdePrivacidade,
                  onChanged: (value) {
                    setState(() {
                      _PoliticasdePrivacidade = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.verdeClaro; // fundo verde quando marcado
                    }
                    return Colors.white; // fundo cinza quando desmarcado
                  }),
                  checkColor: Colors.white, // cor do "check"
                ),
                const Expanded(
                  child: Text(
                    "Li e estou ciente quanto às medidas de tratamento dos meus dados conforme descrito na Política de Privacidade do Banco.",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botão Criar Conta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.botaoCriarConta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Criar Conta",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]
          ))));
          }
          }
