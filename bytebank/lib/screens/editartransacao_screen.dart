// editartransacao_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//Adicionando os providers
import 'package:provider/provider.dart';
import 'package:bytebank/providers/saldoprovider.dart';

import 'package:bytebank/models/transacao.dart';

class EditarTransacaoScreen extends StatefulWidget {
  // 1. Recebe o objeto Transacao no construtor
  final Transacao transacaoParaEditar;

  const EditarTransacaoScreen({
    super.key,
    required this.transacaoParaEditar,
  });

  @override
  State<EditarTransacaoScreen> createState() => _EditarTransacaoScreenState();
}

class _EditarTransacaoScreenState extends State<EditarTransacaoScreen> {
  //Controllers para campos de texto
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;

  //Variáveis de estado para Dropdowns
  late String _tipoSelecionado;
  late String _categoriaSelecionada;

  // Variável de estado para a Data/Hora original
  late DateTime _dataOriginal;
  late TimeOfDay _horaOriginal;

  final ImagePicker _picker = ImagePicker();
  // Comprovante (File) carregado pelo usuário
  File? _novoComprovante;
  // Variável para controlar se o comprovante atual deve ser removido
  late bool _removerComprovanteAtual;


  // Form Key
  final _formKey = GlobalKey<FormState>();

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


  @override
  void initState() {
    super.initState();
    final t = widget.transacaoParaEditar;
    
    // Inicializa os controllers com os valores atuais da transação
    _descricaoController = TextEditingController(text: t.descricao);
    
    // Formata o valor para edição (ex: 1250.50)
    _valorController = TextEditingController(text: t.valor.toStringAsFixed(2));

    // Inicializa as variáveis de estado para Dropdowns
    _tipoSelecionado = t.tipo;
    _categoriaSelecionada = t.categoria;

    // Inicializa o controle de comprovante
    _removerComprovanteAtual = false;

    // Converte Data e Hora (dd-MM-yyyy e HH:mm:ss) para objetos DateTime e TimeOfDay
    try {
      final String fullDateString = "${t.data} ${t.hora}";
      _dataOriginal = DateFormat('dd-MM-yyyy HH:mm:ss').parse(fullDateString);
      _horaOriginal = TimeOfDay.fromDateTime(_dataOriginal);
    } catch (e) {
      // Fallback ou tratamento de erro se o parsing falhar
      _dataOriginal = DateTime.now();
      _horaOriginal = TimeOfDay.now();
      debugPrint("Erro ao fazer parse de Data/Hora: $e");
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }
  
  // Função para simular o processo de salvamento
  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      // Obter novos valores dos campos
      final double novoValor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? widget.transacaoParaEditar.valor;
      final String novoTipo = _tipoSelecionado;

      // Obter valores originais para o cálculo do saldo
      final double valorOriginal = widget.transacaoParaEditar.valor;
      final String tipoOriginal = widget.transacaoParaEditar.tipo;
      
      //Criar um novo objeto Transacao com os dados ATUALIZADOS
      final Transacao transacaoAtualizada = Transacao(
        idTransacao: widget.transacaoParaEditar.idTransacao,
        tipo: novoTipo,
        valor: novoValor,
        idconta: widget.transacaoParaEditar.idconta,
        saldoAnterior: widget.transacaoParaEditar.saldoAnterior, 
        descricao: _descricaoController.text,
        categoria: _categoriaSelecionada,
        // O saldoFinal agora representa o novo valor da transação no DB
        saldoFinal: novoValor, 
      );

      try {
        // Chamar a função de atualização no modelo
        // Passamos o objeto ORIGINAL para que o método atualize as referências e o histórico.
        await transacaoAtualizada.atualizarTransacao(
          widget.transacaoParaEditar,
          _novoComprovante,
          _removerComprovanteAtual
        );
        
        // Chamar a função de ajuste de saldo no SaldoProvider
        await Provider.of<SaldoProvider>(context, listen: false).ajustarSaldoAposEdicao(
          context,
          valorOriginal,
          tipoOriginal,
          novoValor,
          novoTipo,
        );

        if (!mounted) return;
        
        // Exibir sucesso e voltar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso!')),
        );
        Navigator.pop(context, true);

      } catch (e) {
        // Exibir erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao atualizar: ${e.toString()}')),
        );
      }
    }
  }
  

  Future<void> _mostrarOpcoesComprovante() async {
    // Opções de comprovante
    List<Widget> options = [
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
    ];

    // Adiciona a opção de remover se houver um comprovante (original ou novo)
    if (widget.transacaoParaEditar.anexoUrl != null && !_removerComprovanteAtual || _novoComprovante != null) {
      options.add(
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text("Remover Comprovante Atual", style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.of(context).pop();
            setState(() {
              _novoComprovante = null;
              _removerComprovanteAtual = true;
            });
          },
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Comprovante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options,
        ),
      ),
    );
  }

  Future<void> _selecionarComprovante(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _novoComprovante = File(pickedFile.path);
        _removerComprovanteAtual = false;
      });
    }
  }

  // Helper para determinar o texto do botão
  String _getComprovanteButtonText() {
    if (_novoComprovante != null) {
      return "Novo Comprovante Selecionado";
    } else if (widget.transacaoParaEditar.anexoUrl != null && !_removerComprovanteAtual) {
      return "Comprovante Atual (Clique para substituir)";
    } else if (_removerComprovanteAtual) {
      return "Comprovante Removido (Clique para adicionar)";
    }
    return "Selecionar comprovante (Opcional)";
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

    // Condição para exibir o comprovante
    final bool hasComprovante = _novoComprovante != null || 
                                (widget.transacaoParaEditar.anexoUrl != null && !_removerComprovanteAtual);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Transação"),
        backgroundColor: AppColors.corBytebank,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              //Campo Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: _inputDecoration("Descrição", Icons.description),
                validator: (value) => value!.isEmpty ? 'A descrição é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              
              //Campo Valor
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration("Valor", Icons.monetization_on),
                validator: (value) {
                  if (value!.isEmpty) return 'O valor é obrigatório';
                  // Garante que o valor é válido mesmo com vírgula
                  if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              //Dropdown Tipo de Transação
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transação',
                  border: OutlineInputBorder(),
                ),
                value: _tipoSelecionado,
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

              //Dropdown Categoria
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                value: _categoriaSelecionada,
                items: categoriasTransacaoString.map((String value) {
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

              //Exibição do Comprovante
              if (hasComprovante) ...[
                const Text("Comprovante:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cinzaCardTexto),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _novoComprovante != null
                      ? Image.file(
                          _novoComprovante!,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.transacaoParaEditar.anexoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(child: Text('Erro ao carregar imagem')),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // --- Fim da Exibição do Comprovante ---

              // Botão de Comprovante
                ElevatedButton(
                  onPressed: _mostrarOpcoesComprovante,
                  child: Text(_getComprovanteButtonText()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.corBytebank,
                  ),
                ),

                const SizedBox(height: 16),

              // Campo Data
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Data Original: ${DateFormat('dd/MM/yyyy').format(_dataOriginal)}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              //Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvarEdicao,
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar Alterações"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}