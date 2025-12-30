import 'package:bytebank/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:firebase_database/firebase_database.dart';

import 'package:bytebank/features/auth/data/models/usuariomodel.dart';

// Mudar para ConsumerStatefulWidget
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> { 
  // Chave global para o formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  bool _PoliticasdePrivacidade = false;
  String _errorMessage = '';

  @override
  void dispose() {
    // Descartar os controllers quando o widget for removido
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _register() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return; // Retorna se a validação do formulário falhar
    }

    if (!_PoliticasdePrivacidade) {
      setState(() {
        _errorMessage = "Você deve concordar com as Políticas de Privacidade.";
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 1. Atualizar nome no Firebase Auth
        await user.updateDisplayName(_nomeController.text.trim());
        
        // 2. Salvar dados adicionais no Realtime Database
        final usuarioModel = UsuarioModel(
          id: user.uid,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          dataNascimento: DateTime.now(),
        );

        // Salvar em 'usuarios'
        final dbRefUsuarios =
            FirebaseDatabase.instance.ref('usuarios/${user.uid}');
        await dbRefUsuarios.set(usuarioModel.toMap());

        // 3. Inicializar dados básicos em 'contas' (necessário para o SaldoProvider)
        final dbRefContas =
            FirebaseDatabase.instance.ref('contas/${user.uid}');
        await dbRefContas.set({
          'nomeUsuario': _nomeController.text.trim(),
          'saldo': 0.0,
        });

        //Sucesso: Navegar para a tela inicial (Login ou Dashboard)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Conta criada com sucesso! Faça login."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volta para a tela de login
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else {
        message = 'Erro ao criar conta. Tente novamente. (${e.message})';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... restante do build permanece o mesmo, sem chamadas ao Provider.of
    return Scaffold(
        appBar: AppBar(
          title: const Text("Criar Conta"),
          backgroundColor: AppColors.corBytebank,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo Nome
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail.';
                      }
                      if (!value.contains('@')) {
                        return 'E-mail inválido.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Campo Senha
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha.';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Checkbox de Política de Privacidade
                  Row(
                    children: [
                      Checkbox(
                        value: _PoliticasdePrivacidade,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _PoliticasdePrivacidade = newValue ?? false;
                          });
                        },
                        activeColor: AppColors.botaoCriarConta,
                      ),
                      const Expanded(
                        child: Text(
                          "Eu li e concordo com a Política de Privacidade.",
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Mensagem de erro
                  if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // Botão Criar Conta
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _register, // Chama a função que agora valida e registra
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
              ],
            ),
          ),
        ),
      )
    );
  }
}