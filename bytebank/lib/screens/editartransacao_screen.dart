import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  // 2. Controllers para campos de texto
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;

  // 3. Variáveis de estado para Dropdowns
  late String _tipoSelecionado;
  late String _categoriaSelecionada;

  // Variável de estado para a Data/Hora original
  late DateTime _dataOriginal;
  late TimeOfDay _horaOriginal;

  // Form Key
  final _formKey = GlobalKey<FormState>();


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

    // Converte Data e Hora (dd-MM-yyyy e HH:mm:ss) para objetos DateTime e TimeOfDay
    try {
      final String fullDateString = "${t.data} ${t.hora}"; // e.g., "30-09-2025 10:07:00"
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
      // 1. Obter os novos valores
      final double novoValor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? widget.transacaoParaEditar.valor;
      
      // 2. Criar um novo objeto Transacao com os dados atualizados
      final Transacao transacaoAtualizada = Transacao(
        idTransacao: widget.transacaoParaEditar.idTransacao,
        tipo: _tipoSelecionado,
        valor: novoValor,
        idconta: widget.transacaoParaEditar.idconta,
        saldoAnterior: widget.transacaoParaEditar.saldoAnterior, // Deve ser recalculado na atualização real
        descricao: _descricaoController.text,
        categoria: _categoriaSelecionada,
        // Ao editar, o saldo final deve ser recalculado no Provider/Model
        saldoFinal: novoValor, // Placeholder
      );

      // 3. Chamar a função de atualização no modelo (ou Provider)
      try {
        // Obter o mês/ano da transação original para o Firebase (MM-yyyy)
        final mesTransacao = DateFormat('MM-yyyy').parse(widget.transacaoParaEditar.data);

        await transacaoAtualizada.atualizarTransacao(mesTransacao);
        
        // Exibir sucesso e voltar para a tela anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso!')),
        );
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso

      } catch (e) {
        // Exibir erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao atualizar: ${e.toString()}')),
        );
      }
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
              // --- Campo Descrição ---
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: "Descrição"),
                validator: (value) => value!.isEmpty ? 'A descrição é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              
              // --- Campo Valor ---
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Valor (R\$)",
                  hintText: "0.00",
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'O valor é obrigatório';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // --- Dropdown Tipo de Transação ---
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

              // --- Dropdown Categoria ---
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

              // --- Campo Data---
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
              
              // --- Botão Salvar ---
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