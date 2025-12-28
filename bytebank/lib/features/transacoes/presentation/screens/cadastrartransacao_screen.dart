import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bytebank/app_colors.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart'; // Certifique-se que os Enums estão aqui
import 'package:bytebank/features/transacoes/presentation/widgets/transacao_form.dart';
import '../providers/cadastrar_transacao_notifier.dart';

class CadastrarTransacaoScreen extends ConsumerStatefulWidget {
  const CadastrarTransacaoScreen({super.key});

  @override
  ConsumerState<CadastrarTransacaoScreen> createState() => _CadastrarTransacaoScreenState();
}

class _CadastrarTransacaoScreenState extends ConsumerState<CadastrarTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descController = TextEditingController();

  // MUDANÇA AQUI: Agora usamos os Enums definidos no Model
  TipoTransacao _tipo = TipoTransacao.deposito;
  CategoriaTransacao _categoria = CategoriaTransacao.outros;
  File? _image;

  void _confirmarCancelamento() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancelar Cadastro"),
        content: const Text("Deseja cancelar o cadastro de uma nova transação?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Não", style: TextStyle(color: Colors.red))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Sim", )
          ),
        ],
      ),
    );

    if (confirmar == true) Navigator.pop(context);
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      
      final transacao = TransacaoModel(
        idTransacao: now.millisecondsSinceEpoch.toString(),
        categoria: _categoria, 
        data: DateFormat('dd-MM-yyyy').format(now),
        descricao: _descController.text,
        hora: DateFormat('HH:mm:ss').format(now),
        saldo: 0, 
        saldoAnterior: 0,
        status: 'Concluída',
        tipoTransacao: _tipo, 
        valor: double.parse(_valorController.text),
        historico: [],
        anexoUrl: '', 
      );

      ref.read(cadastrarTransacaoProvider.notifier).cadastrar(
            transacao: transacao,
            arquivoComprovante: _image,
          ).then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transação cadastrada com sucesso!"))
              );
              Navigator.pop(context);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadastrarTransacaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
        backgroundColor: AppColors.corBytebank,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: _confirmarCancelamento
        ),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TransacaoForm(
                  formKey: _formKey,
                  valorController: _valorController,
                  descController: _descController,
                  onTipoChanged: (TipoTransacao v) => setState(() => _tipo = v),
                  onCategoriaChanged: (CategoriaTransacao v) => setState(() => _categoria = v),
                  onImagePicked: (file) => setState(() => _image = file),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _confirmarCancelamento,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.corBytebank,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}