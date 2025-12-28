import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/presentation/providers/transacoesprovider.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/app_colors.dart';
import 'editartransacao_screen.dart';

class ExtratoScreen extends ConsumerWidget {
  const ExtratoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pegando as transações do mês vigente
    final transacoesAsync = ref.watch(transacoesProvider);

    return Scaffold(
      body: transacoesAsync.when(
        data: (transacoes) {
          final listaAtiva = transacoes.where((t) => t.status != 'excluida').toList();

          if (listaAtiva.isEmpty) {
            return const Center(child: Text("Nenhuma transação este mês."));
          }

          return ListView.builder(
            itemCount: listaAtiva.length,
            itemBuilder: (context, index) {
              final transacao = listaAtiva[index];

              return Dismissible(
                key: Key(transacao.idTransacao),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) => _confirmarExclusao(context, ref, transacao),
                child: ListTile(
                  leading: Icon(_getIconForTipo(transacao.tipoTransacao), color: AppColors.corBytebank),
                  title: Text(transacao.descricao,
                  style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),),
                  subtitle: Text("${transacao.data} - ${transacao.categoria.label}",
                  style: TextStyle(
                  color: Colors.grey[600],
                  ),  
                  ),
                  trailing: Text(
                    "R\$ ${transacao.valor.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transacao.tipoTransacao == TipoTransacao.deposito ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () => _navegarParaEdicao(context, transacao),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erro: $err")),
      ),
    );
  }

  IconData _getIconForTipo(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.deposito: return Icons.arrow_upward;
      case TipoTransacao.pagamento: return Icons.receipt_long;
      case TipoTransacao.transferencia: return Icons.swap_horiz;
      case TipoTransacao.investimento: return Icons.trending_up;
    }
  }

  Future<bool?> _confirmarExclusao(BuildContext context, WidgetRef ref, TransacaoModel transacao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Transação"),
        content: const Text("Deseja realmente excluir? O valor será estornado do seu saldo."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Não")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Excluir", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Chama a lógica de soft delete no provider
      await ref.read(transacoesProvider.notifier).excluirTransacao(transacao);
    }
    return confirmar;
  }

  void _navegarParaEdicao(BuildContext context, TransacaoModel transacao) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarTransacaoScreen(transacao: transacao)),
    );
  }
}