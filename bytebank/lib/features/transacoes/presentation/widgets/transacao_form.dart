import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bytebank/app_colors.dart';

//Importando o model de Transacao
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';

class TransacaoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController valorController;
  final TextEditingController descController;
  final Function(TipoTransacao) onTipoChanged;
  final Function(CategoriaTransacao) onCategoriaChanged;
  final Function(File?) onImagePicked;
  final TipoTransacao tipoInicial;
  final CategoriaTransacao categoriaInicial;

  const TransacaoForm({
    super.key,
    required this.formKey,
    required this.valorController,
    required this.descController,
    required this.onTipoChanged,
    required this.onCategoriaChanged,
    required this.onImagePicked,
    this.tipoInicial = TipoTransacao.deposito,
    this.categoriaInicial = CategoriaTransacao.outros,
  });

  @override
  State<TransacaoForm> createState() => _TransacaoFormState();
}

class _TransacaoFormState extends State<TransacaoForm> {
  late TipoTransacao _tipo;
  late CategoriaTransacao _categoria;
  File? _image;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
    _categoria = widget.categoriaInicial;
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.corBytebank),
      prefixIcon: Icon(icon, color: AppColors.cinzaCardTexto),
      prefixText: prefixText,
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      widget.onImagePicked(_image);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Câmera"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeria"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // --- Dropdown Tipo Transação ---
          DropdownButtonFormField<TipoTransacao>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo de Transação'),
            items: TipoTransacao.values.map((t) => DropdownMenuItem(
              value: t, 
              child: Text(t.label)
            )).toList(),
            onChanged: (v) { 
              if (v != null) {
                setState(() => _tipo = v); 
                widget.onTipoChanged(v); 
              }
            },
          ),

          const SizedBox(height: 16),

          // --- Dropdown Categoria ---
          DropdownButtonFormField<CategoriaTransacao>(
            initialValue: _categoria,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: CategoriaTransacao.values.map((c) => DropdownMenuItem(
              value: c, 
              child: Text(c.label)
            )).toList(),
            onChanged: (v) { 
              if (v != null) {
                setState(() => _categoria = v); 
                widget.onCategoriaChanged(v); 
              }
            },
          ),
          
          const SizedBox(height: 16),

          // Campo Valor
          TextFormField(
            controller: widget.valorController,
            decoration: _inputDecoration("Valor", Icons.monetization_on, prefixText: 'R\$ '),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Informe o valor' : null,
          ),

          const SizedBox(height: 16),

          // Campo Descrição
          TextFormField(
            controller: widget.descController,
             decoration: _inputDecoration("Descrição", Icons.description),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe uma descrição' : null,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, 
            child: OutlinedButton.icon(
              onPressed: _showImageOptions,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.corBytebank),
              ),
              icon: Icon(
                _image == null ? Icons.add_a_photo : Icons.check_circle, 
                color: AppColors.corBytebank
              ),
              label: Text(
                _image == null ? 'Selecionar Comprovante' : 'Comprovante Selecionado',
                style: const TextStyle(color: AppColors.corBytebank),
              ),
            ),
          ),
        ],
      ),
    );
  }
}