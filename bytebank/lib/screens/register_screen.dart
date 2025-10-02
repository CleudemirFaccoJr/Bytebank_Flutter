import 'package:bytebank/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    // Validação do checkbox de política de privacidade
    if (!_PoliticasdePrivacidade) {
      setState(() {
        _errorMessage =
            "Você precisa aceitar a política de privacidade para continuar.";
      });
      return;
    } else {
      setState(() {
        _errorMessage =
            ''; // Limpa a mensagem de erro se o checkbox estiver marcado
      });
    }

    try {
      // Tenta criar o usuário no Firebase
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Envia o nome do usuário para o Firebase, se necessário
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nomeController.text);
      }

      // Mostrar SnackBar de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Conta criada com sucesso!"),
            backgroundColor: AppColors.verdeClaro,
          ),
        );

        // Voltar para a tela anterior
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;

      //Trata o erro de email já em uso
      if (e.code == 'email-already-in-use') {
        message = 'O email já está em uso';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do email é inválido';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca, use pelo menos 6 caracteres';
      } else {
        message = e.message ?? "Erro desconhecido";
      }

      //Snackbar de Erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      setState(() {
        // Exibe a mensagem de erro do Firebase
         _errorMessage = message;
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
        borderSide: const BorderSide(
          color: AppColors.verdeClaroHover,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        // Adicionado para estilizar erro
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Adicionado para estilizar erro
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 2),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),

      //Body do Widget - Conteudo
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            // Envolvemos os TextFields em um Form
            key: _formKey, // Atribuir a GlobalKey ao Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Preencha os campos abaixo para criar a sua conta corrente!",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                //Campo Nome (mudado para TextFormField para validação)
                TextFormField(
                  controller: _nomeController,
                  decoration: _inputDecoration("Nome", Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu nome.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                //Campo Email (mudado para TextFormField para validação)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu email.';
                    }
                    // Expressão regular básica para validar o formato do email
                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                    RegExp regExp = RegExp(pattern);
                    if (!regExp.hasMatch(value)) {
                      return 'Por favor, digite um email válido.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                //Campo Senha (mudado para TextFormField para validação)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Senha", Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua senha.';
                    }
                    if (value.length < 6) {
                      // O Firebase Auth exige no mínimo 6 caracteres
                      return 'A senha deve ter no mínimo 6 caracteres.';
                    }
                    return null;
                  },
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
                          // Limpa a mensagem de erro do checkbox ao interagir
                          if (_PoliticasdePrivacidade) {
                            _errorMessage = '';
                          }
                        });
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors
                              .verdeClaro; // fundo verde quando marcado
                        }
                        return AppColors
                            .cinzaCardTexto; // Cor para quando desmarcado
                      }),
                      checkColor: Colors.white, // cor do "check"
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Li e estou ciente quanto às medidas de tratamento dos meus dados conforme descrito na Política de Privacidade do Banco.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                // Mensagem de erro (para checkbox ou Firebase Auth)
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
      ),
    );
  }
}
