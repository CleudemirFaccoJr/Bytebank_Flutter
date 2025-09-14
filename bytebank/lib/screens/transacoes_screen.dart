import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

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
  investimento 
  }

  typedef categoriaTransacao = DropdownMenuEntry<CategoriaTransacao>;

enum CategoriaTransacao { 
  selecioneCategoria, 
  saude, 
  lazer,
  investimento,
  transporte,
  alimentacao,
  outros 
  }

class _TransacoesScreenState extends State<TransacoesScreen> {
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  //Aqui precisa ainda colocar o controller responsável pelo upload de arquivos

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
        borderSide: const BorderSide(color: AppColors.verdeClaroHover, width: 2),
      ),
    );
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
        padding:  const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conteúdo da tela de transações
            Text(
              "Nova Transação",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Campos de entrada para detalhes da transação
            DropdownMenu<TipoTransacao>(
              width: double.infinity,
              controller: tipoController,
              label: const Text("Tipo de Transação"),
              initialSelection: TipoTransacao.selecioneTransacao,
              dropdownMenuEntries: const [
                tipoTransacao(
                  value: TipoTransacao.selecioneTransacao,
                  label: "Selecione um tipo de Transação",
                  enabled: false,
                ),
                tipoTransacao(
                  value: TipoTransacao.deposito,
                  label: "Depósito",
                ),
                tipoTransacao(
                  value: TipoTransacao.transferencia,
                  label: "Transferência",
                ),
                tipoTransacao(
                  value: TipoTransacao.pagamento,
                  label: "Pagamento",
                ),
                tipoTransacao(
                  value: TipoTransacao.investimento,
                  label: "Investimento",
                ),
              ],
            ),

            const SizedBox(height: 16),

            //Campos de Entrada para Categoria da Transação
            DropdownMenu<CategoriaTransacao>(
              width: double.infinity,
              controller: categoriaController,
              label: const Text("Categoria de Transação"),
              initialSelection: CategoriaTransacao.selecioneCategoria,
              dropdownMenuEntries: const [
                categoriaTransacao(
                  value: CategoriaTransacao.selecioneCategoria,
                  label: "Selecione uma categoria",
                  enabled: false,
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.saude,
                  label: "Saúde",
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.lazer,
                  label: "Lazer         ",
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.transporte,
                  label: "Transporte",
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.investimento,
                  label: "Investimento",
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.alimentacao,
                  label: "Alimentação",
                ),
                categoriaTransacao(
                  value: CategoriaTransacao.outros,
                  label: "Outros",
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                "Valor", Icons.monetization_on,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descricaoController,
              decoration: _inputDecoration(
                "Descrição", Icons.description,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: (){
                      // Lógica para cancelar a transação
                      Navigator.pop(context);
                  },
                   child: const Text("Cancelar"),
                   style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                      )
                      ),
                  ), 
                ), 
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(
                  onPressed: (){
                     // Lógica para salvar a transação
                  },
                   child: const Text("Salvar"),
                   style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.corBytebank,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                      )
                      ),
                  ), 
                ),
              ],
            )
          ],
         ), 
       ),
     ),
    );
   }
} 
