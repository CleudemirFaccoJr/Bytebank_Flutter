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

class TransacoesScreen extends StatefulWidget {
  @override
  _TransacoesScreenState createState() => _TransacoesScreenState();
}

typedef tipoTransacao = DropdownMenuEntry<TipoTransacao>;

enum TipoTransacao {
  selecioneTransacao,
  deposito,
  transferencia,
  pagamento,
  investimento,
}

typedef categoriaTransacao = DropdownMenuEntry<CategoriaTransacao>;

enum CategoriaTransacao {
  selecioneCategoria,
  saude,
  lazer,
  investimento,
  transporte,
  alimentacao,
  outros,
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  File? _comprovante;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  TipoTransacao? _tipoSelecionado;
  CategoriaTransacao? _categoriaSelecionada;

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

      // Criar o objeto Transacao
      final transacao = Transacao(
        idTransacao: DateTime.now().millisecondsSinceEpoch.toString(),
        valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
        tipoTransacao: _tipoSelecionado.toString().split('.').last,
        categoria: _categoriaSelecionada.toString().split('.').last,
        descricao: descricaoController.text,
        data: DateTime.now(),
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
          transacao.tipoTransacao,
        );

        //Recarregar a lista de transações na tela anterior, se necessário
        await Provider.of<TransacoesProvider>(
          context,
          listen: false,
        ).buscarTransacoes(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transação salva com sucesso! 🎉")),
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

                // Dropdown Tipo de Transação
                DropdownMenu<TipoTransacao>(
                  width: double.infinity,
                  controller: tipoController,
                  onSelected: (TipoTransacao? tipo) {
                    _tipoSelecionado = tipo;
                  },
                  label: const Text("Tipo de Transação"),
                  initialSelection: TipoTransacao.selecioneTransacao,
                  dropdownMenuEntries: [
                    tipoTransacao(
                      value: TipoTransacao.selecioneTransacao,
                      label: "Selecione um tipo de Transação",
                      enabled: false,
                    ),
                    // ... (Outros tipos de transação)
                    // IMPORTANTE: O `label` deve ser o que será salvo em `tipoController.text`
                    tipoTransacao(
                      value: TipoTransacao.deposito,
                      label: "deposito",
                    ),
                    tipoTransacao(
                      value: TipoTransacao.transferencia,
                      label: "transferencia",
                    ),
                    tipoTransacao(
                      value: TipoTransacao.pagamento,
                      label: "pagamento",
                    ),
                    tipoTransacao(
                      value: TipoTransacao.investimento,
                      label: "investimento",
                    ),
                  ],
                ),
            
                const SizedBox(height: 16),

                // Dropdown Categoria de Transação
                DropdownMenu<CategoriaTransacao>(
                  width: double.infinity,
                  controller: categoriaController,
                  // NOVO: Adicionando validação
                  onSelected: (CategoriaTransacao? categoria) {
                    _categoriaSelecionada = categoria;
                  },
                  label: const Text("Categoria de Transação"),
                  initialSelection: CategoriaTransacao.selecioneCategoria,
                  dropdownMenuEntries: [
                    categoriaTransacao(
                      value: CategoriaTransacao.selecioneCategoria,
                      label: "Selecione uma categoria",
                      enabled: false,
                    ),
                    // ... (Outras categorias)
                    // IMPORTANTE: O `label` deve ser o que será salvo em `categoriaController.text`
                    categoriaTransacao(
                      value: CategoriaTransacao.saude,
                      label: "saude",
                    ),
                    categoriaTransacao(
                      value: CategoriaTransacao.lazer,
                      label: "lazer",
                    ),
                    categoriaTransacao(
                      value: CategoriaTransacao.transporte,
                      label: "transporte",
                    ),
                    categoriaTransacao(
                      value: CategoriaTransacao.investimento,
                      label: "investimento",
                    ),
                    categoriaTransacao(
                      value: CategoriaTransacao.alimentacao,
                      label: "alimentacao",
                    ),
                    categoriaTransacao(
                      value: CategoriaTransacao.outros,
                      label: "outros",
                    ),
                  ],
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
