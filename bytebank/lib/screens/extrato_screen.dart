import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

class ExtratoScreen extends StatelessWidget {
  const ExtratoScreen({super.key});

  void _abrirFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Mais Filtros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: const Text("Todas"),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text("Entradas"),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text("Saídas"),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Período
              TextField(
                decoration: InputDecoration(
                  hintText: "Selecione o período desejado",
                  prefixIcon: const Icon(Icons.calendar_today,
                      color: AppColors.corBytebank),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ordem de lançamento
              const Text(
                "Ordem de Lançamento",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text("Mais recentes"),
                    value: "recentes",
                    groupValue: "recentes",
                    onChanged: (_) {},
                  ),
                  RadioListTile(
                    title: const Text("Mais antigos"),
                    value: "antigos",
                    groupValue: "recentes",
                    onChanged: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Categorias (exemplo com chips)
              const Text(
                "Categorias",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text("Lazer (99)"),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text("Alimentação (99)"),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Limpar"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Filtrar"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampoBusca(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.cinzaCardTexto),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.verdeClaroHover,
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _abrirFiltros(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTransacao(String nome, String detalhes, String valor) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        nome,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(detalhes),
      trailing: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGrupoTransacoes(String data, List<Map<String, String>> transacoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...transacoes.map((t) => _buildTransacao(
              t["nome"]!,
              t["detalhes"]!,
              t["valor"]!,
            )),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Extrato")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCampoBusca(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildGrupoTransacoes("Hoje - 15/09/2025", [
                    {
                      "nome": "QuemRecebeuTransacao",
                      "detalhes": "Hora - tipoTransacao",
                      "valor": "R\$ 60,89"
                    },
                  ]),
                  _buildGrupoTransacoes("14/09/2025", [
                    {
                      "nome": "QuemRecebeuTransacao",
                      "detalhes": "Hora - tipoTransacao",
                      "valor": "R\$ 60,89"
                    },
                    {
                      "nome": "QuemRecebeuTransacao",
                      "detalhes": "Hora - tipoTransacao",
                      "valor": "R\$ 60,89"
                    },
                  ]),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.corBytebank),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Carregar mais",
                        style: TextStyle(color: AppColors.corBytebank),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
