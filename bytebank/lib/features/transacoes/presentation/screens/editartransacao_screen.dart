import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/features/transacoes/presentation/widgets/transacao_form.dart';
import 'package:bytebank/features/transacoes/presentation/providers/transacoesprovider.dart';
import 'package:bytebank/app_colors.dart';

class EditarTransacaoScreen extends ConsumerStatefulWidget {
  final TransacaoModel transacao;
  const EditarTransacaoScreen({super.key, required this.transacao});

  @override
  ConsumerState<EditarTransacaoScreen> createState() => _EditarTransacaoScreenState();
}

class _EditarTransacaoScreenState extends ConsumerState<EditarTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valorController;
  late TextEditingController _descController;
  late TipoTransacao _tipo;
  late CategoriaTransacao _categoria;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(text: widget.transacao.valor.toString());
    _descController = TextEditingController(text: widget.transacao.descricao);
    _tipo = widget.transacao.tipoTransacao;
    _categoria = widget.transacao.categoria;
  }

  void _salvarAlteracoes() {
    if (_formKey.currentState!.validate()) {
      final transacaoEditada = widget.transacao.copyWith(
        descricao: _descController.text,
        valor: double.parse(_valorController.text),
        tipoTransacao: _tipo,
        categoria: _categoria,
      );

      ref.read(transacoesProvider.notifier)
         .editarTransacao(oldTransacao: widget.transacao, newTransacao: transacaoEditada)
         .then((_) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Transação"), backgroundColor: AppColors.corBytebank),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TransacaoForm(
              formKey: _formKey,
              valorController: _valorController,
              descController: _descController,
              tipoInicial: _tipo,
              categoriaInicial: _categoria,
              onTipoChanged: (v) => _tipo = v,
              onCategoriaChanged: (v) => _categoria = v,
              onImagePicked: (file) {}, 
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.corBytebank,
                minimumSize: const Size(double.infinity, 50)
              ),
              child: const Text("Salvar Alterações", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}