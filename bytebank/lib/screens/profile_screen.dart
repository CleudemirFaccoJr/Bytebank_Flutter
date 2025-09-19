import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:firebase_database/firebase_database.dart';

//Importanto o Mask formatter
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

//Importando o AuthProvider
import 'package:bytebank/providers/authprovider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController nascimentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  final nascimentoMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() { 
    super.initState(); 

    // Carrega os dados do usuário ao iniciar a tela
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    nomeController.text = authProvider.userName;
    emailController.text = authProvider.user?.email ?? '';
    _fetchNascimentoFromDatabase();
  }

  // Método para buscar a data de nascimento do banco de dados (se houver)
  void _fetchNascimentoFromDatabase() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;
    if (uid == null) return;

    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('contas/$uid/dataNascimento').get();
    if (snapshot.exists) {
      nascimentoController.text = snapshot.value as String;
    }
  }

  @override
  void dispose() { 
    nomeController.dispose();
    nascimentoController.dispose();
    emailController.dispose();
    novaSenhaController.dispose();
    repetirSenhaController.dispose();
    super.dispose();
  }

  //Método para exibir dialogo de confirmação
  Future<void> _showConfirmationDialog(bool isPasswordChange) async {
    final String mensagem = isPasswordChange
        ? 'Você está atualizando sua senha. Após confirmar, você será deslogado por segurança.'
        : 'Você está atualizando seus dados, tem certeza que deseja continuar?';

        return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text('Confirmar Atualização'),
              content: Text(mensagem),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirmar'),
                  onPressed: () async {
                    Navigator.of(context).pop(); 
                    // Correção: Alterado para _atualizarDadosUsuario
                    _atualizarDadosUsuario(isPasswordChange);
                  },
                ),
              ],
            );
          }
        );
  }

  Future<void> _atualizarDadosUsuario(bool isPasswordChange) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null){
      return;
    }

    try{
      await user.updateDisplayName(nomeController.text);

      if (isPasswordChange) {
          await authProvider.atualizarSenha(
          senhaAtualController.text,
          novaSenhaController.text,
        );
    }
    if (nascimentoController.text.isNotEmpty) {
        final dbRef = FirebaseDatabase.instance.ref('contas/${user.uid}');
        await dbRef.update({
          'dataNascimento': nascimentoController.text,
        });
      }

      await user.reload();
      authProvider.notifyListeners();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );

      if (!isPasswordChange) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Erro ao atualizar dados: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
     final authProvider = Provider.of<AuthProvider>(context);
    //Pegando a data de criação da conta e formatando
    final DateTime? creationDate = authProvider.user?.metadata.creationTime;
    String formattedDate = creationDate != null
        ? DateFormat('dd/MM/yyyy').format(creationDate)
        : 'Data não disponível';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + Nome + Dados da conta
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Agência 0001  •  Conta 4239794/6",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Conosco desde: $formattedDate",
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: const [
                Text(
                  "Meus Dados",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Campos de texto
            _buildTextField("Nome de usuário", nomeController),
           _buildTextField("Data de Nascimento", nascimentoController,
              formatter: nascimentoMaskFormatter),
            _buildTextField("Email", emailController, readOnly: true),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alterar senha",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField("Senha atual", senhaAtualController, obscure: true),
            _buildTextField("Nova senha", novaSenhaController, obscure: true),
            _buildTextField("Repita a senha", repetirSenhaController, obscure: true),

            const SizedBox(height: 25),

            // Botões
            Row(
              children: [
                Expanded(
                  child: _buildOutlinedButton("Cancelar"),
                ),
                const SizedBox(width: 16), 
                Expanded(
                  child: _buildElevatedButton("Atualizar dados"),
                ),
              ],
            ),


            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Excluir conta"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false, bool readOnly = false, MaskTextInputFormatter? formatter}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.verdeClaro),
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
    );
  }

  Widget _buildOutlinedButton(String text) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
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
}