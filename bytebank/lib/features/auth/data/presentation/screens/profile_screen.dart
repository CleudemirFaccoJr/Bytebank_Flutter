import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 

//Importanto o Mask formatter
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

//Importando o AuthProvider do Riverpod
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';
// Importando o UsuarioProvider do Riverpod
import 'package:bytebank/features/auth/data/presentation/providers/usuarioprovider.dart';


// Mudar para ConsumerStatefulWidget
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

// Mudar para ConsumerState
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController nascimentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  final nascimentoMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: { " ": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() { 
    super.initState(); 
    
    Future.microtask(() {
      //Acessa o estado atual do AuthProvider
      final authState = ref.read(authProvider); 
      
      //O email é sempre do Firebase Auth
      emailController.text = authState.user?.email ?? '';

      //O nome de exibição é o do AuthState
      nomeController.text = authState.displayName;

      //Carrega dados adicionais (nascimento) usando o FutureProvider
      //O dado do usuário pode ainda estar carregando, então usamos watch
      ref.watch(usuarioProvider).whenData((usuarioModel) {
        if (usuarioModel != null) {
          // Formata a data de nascimento se existir no modelo
          nascimentoController.text = DateFormat('dd/MM/yyyy').format(usuarioModel.dataNascimento);
        }
      });
    });
  }
  
  //Método de Logout agora usa o Notifier do Riverpod
  void _logout() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }


  //Diálogo de confirmação para Salvar/Atualizar Senha
  void _showConfirmationDialog(bool isPasswordChange) {
    //Acessa o Notifier do AuthProvider para as ações
    final authNotifier = ref.read(authProvider.notifier);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPasswordChange ? 'Atualizar Senha' : 'Salvar Alterações'),
          content: Text(
            isPasswordChange
                ? 'Tem certeza que deseja alterar sua senha e deslogar?'
                : 'Tem certeza que deseja salvar as alterações do seu perfil?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Fecha o diálogo
                
                try {
                  if (isPasswordChange) {
                    // Executa a atualização da senha
                    await authNotifier.atualizarSenha(novaSenhaController.text);
                    // A navegação para o login será feita pelo _logout() implícito no Notifier
                  } else {
                    // Lógica para salvar outras alterações do perfil (se houver)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool readOnly = false,
    bool obscureText = false,
    String? hintText,
    MaskTextInputFormatter? maskFormatter,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscureText,
        inputFormatters: maskFormatter != null ? [maskFormatter] : null,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
  
  // O Widget de Logout
  Widget _buildOutlinedButton(String text) {
    return OutlinedButton(
      onPressed: text == 'Sair da Conta' ? _logout : () => Navigator.of(context).pushReplacementNamed('/dashboard'), 
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
      ),
      child: Text(text), 
    );
  }


  Widget _buildElevatedButton(String text) {
    return ElevatedButton(
      onPressed: () { 
        final bool isPasswordChange = novaSenhaController.text.isNotEmpty || repetirSenhaController.text.isNotEmpty; 

        if (isPasswordChange) { 
          if (novaSenhaController.text != repetirSenhaController.text) { 
            ScaffoldMessenger.of(context).showSnackBar( 
              const SnackBar(content: Text('As senhas não coincidem!')), 
            );
            return; 
          }
          if (senhaAtualController.text.isEmpty) { 
            ScaffoldMessenger.of(context).showSnackBar( 
              const SnackBar(content: Text('Por favor, insira a senha atual para alterar a senha.')), 
            );
            return; 
          }
        }
      
        _showConfirmationDialog(isPasswordChange); 
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.corBytebank, 
        foregroundColor: Colors.white, 
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
      ),
      child: Text(text),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Assinatura para re-renderizar caso o usuárioModel carregue ou mude
    final usuarioAsyncValue = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.corBytebank,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Se o usuário estiver carregando
            usuarioAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erro ao carregar dados do usuário: $e')),
              data: (usuarioModel) {
                // Se o carregamento for bem sucedido, os campos foram preenchidos no initState
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dados do Perfil
                    const Text('Dados Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: nomeController,
                      labelText: 'Nome Completo',
                      icon: Icons.person,
                    ),
                    _buildTextFormField(
                      controller: emailController,
                      labelText: 'E-mail',
                      icon: Icons.email,
                      readOnly: true,
                    ),
                    _buildTextFormField(
                      controller: nascimentoController,
                      labelText: 'Data de Nascimento',
                      icon: Icons.calendar_today,
                      hintText: 'DD/MM/AAAA',
                      maskFormatter: nascimentoMaskFormatter,
                    ),
                    
                    const SizedBox(height: 32),

                    // Alterar Senha
                    const Text('Alterar Senha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: senhaAtualController,
                      labelText: 'Senha Atual',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    _buildTextFormField(
                      controller: novaSenhaController,
                      labelText: 'Nova Senha',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    _buildTextFormField(
                      controller: repetirSenhaController,
                      labelText: 'Repetir Nova Senha',
                      icon: Icons.lock,
                      obscureText: true,
                    ),

                    const SizedBox(height: 32),

                    // Botões
                    _buildElevatedButton('Salvar Alterações'),
                    const SizedBox(height: 16),
                    _buildOutlinedButton('Sair da Conta'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}