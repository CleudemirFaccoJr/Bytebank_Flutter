import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//Importando os Providers
import 'package:provider/provider.dart';
import 'package:bytebank/providers/authprovider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';
import 'package:bytebank/providers/saldoprovider.dart';

//Importanto a Classe Transacao
import 'package:bytebank/models/transacao.dart';

class TransacoesScreen extends StatefulWidget {
  @override
  _TransacoesScreenState createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  File? _comprovante;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? _tipoSelecionado;
  String? _categoriaSelecionada;

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
    );
  }

  Future<void> _mostrarOpcoesComprovante() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Comprovante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeria"),
              onTap: () {
                Navigator.of(context).pop();
                _selecionarComprovante(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Câmera"),
              onTap: () {
                Navigator.of(context).pop();
                _selecionarComprovante(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarComprovante(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _comprovante = File(pickedFile.path);
      });
    }
  }

  Future<void> _salvarTransacao() async {
    if (_formKey.currentState!.validate()) {
      //Obter o userId
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro: Usuário não autenticado.")),
        );
        return;
      }

      final transacao = Transacao(
        idTransacao: DateTime.now().millisecondsSinceEpoch.toString(),
        valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
        tipo: _tipoSelecionado!,
        categoria: _categoriaSelecionada!,
        descricao: descricaoController.text,
        idconta: userId,
        saldoAnterior: 0.0,
        saldoFinal: 0.0,
      );


      try {
        //Adicionar a transação
        await Provider.of<TransacoesProvider>(
          context,
          listen: false,
        ).adicionarTransacao(transacao, userId, comprovante: _comprovante);

        //Atualizar o saldo
        await Provider.of<SaldoProvider>(
          context,
          listen: false,
        ).atualizarSaldo(
          context,
          transacao.valor, 
          transacao.tipo,
        );

        //Recarregar a lista de transações na tela anterior, se necessário
        await Provider.of<TransacoesProvider>(
          context,
          listen: false,
        ).buscarTransacoes(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transação salva com sucesso!")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, preencha todos os campos obrigatórios."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tiposTransacaoString = TipoTransacao.values
        .where((e) => e != TipoTransacao.selecioneTransacao) 
        .map((e) => e.toString().split('.').last)
        .toList();

    final List<String> categoriasTransacaoString = CategoriaTransacao.values
        .where((e) => e != CategoriaTransacao.selecioneCategoria) 
        .map((e) => e.toString().split('.').last)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.corBytebank,
        foregroundColor: Colors.white,
        title: const Text("Transações"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nova Transação",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // --- Dropdown Tipo de Transação ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transação',
                  border: OutlineInputBorder(),
                ),
                initialValue: _tipoSelecionado,
                items: tiposTransacaoString.map((String value) { 
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value[0].toUpperCase() + value.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoSelecionado = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Dropdown Categoria ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                value: _categoriaSelecionada,
                items: categoriasTransacaoString.map((String value) { // Usa categoriasTransacaoString
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value[0].toUpperCase() + value.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoriaSelecionada = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

                // Campo Valor (Trocado para TextFormField para validação)
                TextFormField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration("Valor", Icons.monetization_on),
                  validator: (value) {
                    final valor = double.tryParse(
                      value?.replaceAll(',', '.') ?? '',
                    );
                    if (valor == null || valor <= 0) {
                      return 'Informe um valor válido maior que zero.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Descrição (Trocado para TextFormField para validação)
                TextFormField(
                  controller: descricaoController,
                  decoration: _inputDecoration("Descrição", Icons.description),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A descrição é obrigatória.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Botão de Comprovante (Chama o novo modal)
                ElevatedButton(
                  onPressed: _mostrarOpcoesComprovante, // NOVO MÉTODO
                  child: Text(
                    _comprovante == null
                        ? "Selecionar comprovante (Opcional)"
                        : "Comprovante selecionado",
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.corBytebank,
                  ),
                ),

                const SizedBox(height: 16),

                // Botões de Salvar e Cancelar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancelar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _salvarTransacao, // NOVO MÉTODO
                        child: const Text("Salvar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.corBytebank,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
