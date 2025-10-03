import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//Importanto os providers
import 'package:provider/provider.dart';
import 'package:bytebank/providers/transacoesprovider.dart';
import 'package:bytebank/providers/authprovider.dart';

//Importando o editar
import 'package:bytebank/screens/editartransacao_screen.dart';

import 'package:bytebank/models/transacao.dart';

enum TipoFiltro { todas, entrada, saida }
enum OrdemFiltro { recentes, antigos }

class ExtratoScreen extends StatefulWidget {
  const ExtratoScreen({super.key});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();  
}

class _ExtratoScreenState extends State<ExtratoScreen> {

  //Variáveis para os TextEditingControllers
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  // NOVO: Controlador e estado para a busca
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; 

  //Variáveis para estado de filtro
   String _mesSelecionado = '';
   List<String> _mesesDisponiveisKeys = []; 
   TipoFiltro _tipoFiltro = TipoFiltro.todas;
   OrdemFiltro _ordemFiltro = OrdemFiltro.recentes;
   String? _categoriaFiltro; 


  @override
  void initState() {
    super.initState();
    // Buscar transações ao iniciar a tela
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transacoesProvider = Provider.of<TransacoesProvider>(context, listen: false);
    transacoesProvider.buscarTransacoes(authProvider.userId);

     _mesSelecionado = DateFormat('MM-yyyy').format(DateTime.now());
    
    _fetchMesesDisponiveis();
  }

  // --- Função de busca de meses disponíveis no Firebase ---
  Future<void> _fetchMesesDisponiveis() async {
    final dbRef = FirebaseDatabase.instance.ref().child('transacoes');
    final snapshot = await dbRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final mesesMap = snapshot.value as Map;
      
      final List<String> availableKeys = mesesMap.keys
          .cast<String>()
          .where((key) => RegExp(r'^\d{2}-\d{4}$').hasMatch(key))
          .toList();
      
      // Ordena do mais recente para o mais antigo
      availableKeys.sort((a, b) {
        final dateA = DateFormat('MM-yyyy').parse(a);
        final dateB = DateFormat('MM-yyyy').parse(b);
        return dateB.compareTo(dateA); 
      });

      setState(() {
        _mesesDisponiveisKeys = availableKeys;
        
        // Define o mês selecionado como o mais recente disponível, se o atual não existir
        if (!_mesesDisponiveisKeys.contains(_mesSelecionado) && _mesesDisponiveisKeys.isNotEmpty) {
          _mesSelecionado = _mesesDisponiveisKeys.first;
        } else if (_mesesDisponiveisKeys.isEmpty) {
          // Se não houver meses, mantém o mês atual como fallback (e a lista estará vazia)
          _mesSelecionado = DateFormat('MM-yyyy').format(DateTime.now());
        }
      });
    }

    // Após definir o mês selecionado inicial, carrega as transações
    _buscarTransacoesParaMes(_mesSelecionado);
  }

  //Lógica para busca de transações para o mês selecionado
  void _buscarTransacoesParaMes(String mesAno) {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      if (auth.userId.isNotEmpty) {
          Provider.of<TransacoesProvider>(
            context,
            listen: false,
          ).buscarTransacoes(auth.userId, mesAno: mesAno);
      }
  }

  //Função para puxar um modal ao excluir a transação
  void _confirmarExcluirTransacao(BuildContext context, Transacao transacao) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: const Text("Tem certeza que deseja excluir essa transação?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Não"),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text("Sim"),
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                //Excluir a transação
                await transacao.excluirTransacao();

                // Checa se o widget ainda está na árvore antes de usar o context
                if (!mounted) return; 

                //Mostrar Snackbar de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transação excluída com sucesso!'),
                    duration: Duration(seconds: 3),
                  ),
                );
                
                //Recarregar as transações (força a atualização da lista e do saldo)
                _buscarTransacoesParaMes(_mesSelecionado);

              } catch (e) {
                if (!mounted) return; 
                
                // Lidar com erros de exclusão
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir transação: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  //Função para aplicar os filtros na lista
    List<Transacao> _aplicarFiltros(List<Transacao> transacoes) {
    List<Transacao> listaFiltrada = [...transacoes];
    final String query = _searchQuery.toLowerCase();

    // NOVO: Filtrar por Busca de Texto (Requisito 5)
    if (query.isNotEmpty) {
      listaFiltrada = listaFiltrada.where((t) {
        // Formata o valor para buscar R$ X.XXX,XX, garantindo a busca correta
        final valorFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
            .format(t.valor)
            .toLowerCase();
        
        return t.descricao.toLowerCase().contains(query) ||
               t.tipo.toLowerCase().contains(query) ||
               t.categoria.toLowerCase().contains(query) ||
               valorFormatado.contains(query); 
      }).toList();
    }


    //Filtrar por Tipo (Entrada/Saída/Todas) - Código existente
    if (_tipoFiltro == TipoFiltro.entrada) {
      listaFiltrada =
          listaFiltrada.where((t) => t.tipo.toLowerCase() == 'deposito' || t.tipo.toLowerCase() == 'investimento').toList();
    } else if (_tipoFiltro == TipoFiltro.saida) {
      listaFiltrada =
          listaFiltrada.where((t) => t.tipo.toLowerCase() == 'transferencia' || t.tipo.toLowerCase() == 'pagamento').toList();
    }

    //Filtrar por Categoria - Código existente
    if (_categoriaFiltro != null) {
      listaFiltrada = listaFiltrada
          .where((t) => t.categoria.toLowerCase() == _categoriaFiltro)
          .toList();
    }

    //Ordenar por Data - Código existente
    if (_ordemFiltro == OrdemFiltro.recentes) {
      // Ordena pelo momento da transação (data e hora combinados, do mais novo ao mais antigo)
      listaFiltrada.sort((a, b) {
        final dateTimeA = DateFormat('dd-MM-yyyy HH:mm:ss')
            .parse('${a.data} ${a.hora}:00');
        final dateTimeB = DateFormat('dd-MM-yyyy HH:mm:ss')
            .parse('${b.data} ${b.hora}:00');
        return dateTimeB.compareTo(dateTimeA); // Ordem decrescente (recentes)
      });
    } else {
      // Ordem antiga para nova
      listaFiltrada.sort((a, b) {
        final dateTimeA = DateFormat('dd-MM-yyyy HH:mm:ss')
            .parse('${a.data} ${a.hora}:00');
        final dateTimeB = DateFormat('dd-MM-yyyy HH:mm:ss')
            .parse('${b.data} ${b.hora}:00');
        return dateTimeA.compareTo(dateTimeB); // Ordem crescente (antigos)
      });
    }

    return listaFiltrada;
  }


  //Widget para o Dropdown do mês - Código existente
  Widget _buildDropdownMes({required String mesSelecionadoAtual, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: "Selecione o mês/ano",
        prefixIcon: const Icon(Icons.calendar_today,
            color: AppColors.corBytebank),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
     
      value: mesSelecionadoAtual.isNotEmpty &&
              _mesesDisponiveisKeys.contains(mesSelecionadoAtual)
          ? mesSelecionadoAtual
          : null, 
      hint: const Text("Selecione o mês"),
      items: _mesesDisponiveisKeys.map((String mesAno) {
        return DropdownMenuItem<String>(
          value: mesAno,
          child: Text(
            DateFormat('MM-yyyy').parse(mesAno) ==
                    DateFormat('MM-yyyy').parse(
                        DateFormat('MM-yyyy').format(DateTime.now()))
                ? "Este Mês (${DateFormat('MMM/yyyy', 'pt_BR').format(DateFormat('MM-yyyy').parse(mesAno))})"
                : DateFormat('MMM/yyyy', 'pt_BR').format(
                    DateFormat('MM-yyyy').parse(mesAno)),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }  

  //Função para abrir o modal de filtros - Código existente
  void _abrirFiltros(BuildContext context) {
   
    // Variáveis temporárias para o estado dentro do modal
    String tempMesSelecionado = _mesSelecionado; 
    TipoFiltro tempTipoFiltro = _tipoFiltro;
    OrdemFiltro tempOrdemFiltro = _ordemFiltro;
    String? tempCategoriaFiltro = _categoriaFiltro;

    final transacoesProvider = Provider.of<TransacoesProvider>(context, listen: false);

    // Usando StatefulBuilder para gerenciar o estado dentro do BottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
           
            // Lista de categorias baseada nas transações atuais
            final Set<String> categoriasDisponiveis = transacoesProvider.transacoes
                .map((t) => t.categoria) 
                .toSet();
            
            // Mapeamento de contagem
            final Map<String, int> contagemCategorias = {};
            for (var categoria in categoriasDisponiveis) {
              contagemCategorias[categoria] = transacoesProvider.transacoes
                  .where((t) => t.categoria == categoria)
                  .length;
            }


            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
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

                  // Tabs (Tipo de Transação)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: const Text("Todas"),
                        selected: tempTipoFiltro == TipoFiltro.todas,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTipoFiltro = TipoFiltro.todas;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Entradas"),
                        selected: tempTipoFiltro == TipoFiltro.entrada,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTipoFiltro = TipoFiltro.entrada;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Saídas"),
                        selected: tempTipoFiltro == TipoFiltro.saida,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTipoFiltro = TipoFiltro.saida;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Período (Mês/Ano)
                  //Passando o estado temporário e o callback para o Dropdown
                  _buildDropdownMes(
                    mesSelecionadoAtual: tempMesSelecionado,
                    onChanged: (String? novoMes) {
                      setModalState(() {
                        if (novoMes != null) {
                          tempMesSelecionado = novoMes;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Ordem de lançamento
                  const Text(
                    "Ordem de Lançamento",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      RadioListTile<OrdemFiltro>(
                        title: const Text("Mais recentes"),
                        value: OrdemFiltro.recentes,
                        groupValue: tempOrdemFiltro,
                        onChanged: (value) {
                          setModalState(() {
                            tempOrdemFiltro = value!;
                          });
                        },
                      ),
                      RadioListTile<OrdemFiltro>(
                        title: const Text("Mais antigos"),
                        value: OrdemFiltro.antigos,
                        groupValue: tempOrdemFiltro,
                        onChanged: (value) {
                          setModalState(() {
                            tempOrdemFiltro = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Categorias
                  const Text(
                    "Categorias",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: categoriasDisponiveis.map((categoria) {
                          final nomeUpper =
                              categoria[0].toUpperCase() + categoria.substring(1);
                          final count = contagemCategorias[categoria] ?? 0;
                          return FilterChip(
                            label: Text("$nomeUpper ($count)"),
                            selected: tempCategoriaFiltro == categoria,
                            onSelected: (selected) {
                              setModalState(() {
                                tempCategoriaFiltro = selected ? categoria : null;
                              });
                            },
                          );
                        }).toList(),
                  ),


                  const SizedBox(height: 24),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              // Limpar filtros no modal (local)
                              tempTipoFiltro = TipoFiltro.todas;
                              tempOrdemFiltro = OrdemFiltro.recentes;
                              tempCategoriaFiltro = null;
                            });
                            
                            //Aplicar 'Limpar' na tela principal e recarregar
                            setState(() {
                              _tipoFiltro = tempTipoFiltro;
                              _ordemFiltro = tempOrdemFiltro;
                              _categoriaFiltro = tempCategoriaFiltro;
                              // O mês não é resetado no "Limpar"
                            });

                            _buscarTransacoesParaMes(_mesSelecionado); // Recarrega com os filtros limpos

                            Navigator.pop(context); // Fecha o modal
                          },
                          child: const Text("Limpar"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            //Aplicar filtros e o mês na tela principal
                            setState(() {
                              _tipoFiltro = tempTipoFiltro;
                              _ordemFiltro = tempOrdemFiltro;
                              _categoriaFiltro = tempCategoriaFiltro;
                              _mesSelecionado = tempMesSelecionado; 
                            });

                            // Requisitar as transações para o mês selecionado
                            _buscarTransacoesParaMes(_mesSelecionado);

                            Navigator.pop(context); // Fecha o modal
                          },
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
      },
    );
  }

  //Gerenciar a busca
  Widget _buildCampoBusca(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController, // Usa o controlador de busca
            //Aciona a busca ao apertar "Enter"
            onSubmitted: (value) { 
              setState(() {
                _searchQuery = value;
              });
            },
            //Aciona a busca e atualiza o botão "X" conforme digita
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.cinzaCardTexto),
              //Adiciona o botão 'X' para limpar
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.cinzaCardTexto),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = ''; // Limpa a query no estado
                        });
                      },
                    )
                  : null,
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

  Widget _buildTransacao(Transacao transacao, BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      return Slidable(
        //Chave composta para unicidade
        key: ValueKey('${transacao.idTransacao}-${transacao.data}-${transacao.hora}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(), 
          extentRatio: 0.5,
          children: [
          SlidableAction(
            onPressed: (context) {
              // Ação de Excluir
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ação: Excluir Transação ${transacao.idTransacao} - NÃO NECESSÁRIA NO TCF3')),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
          ),
          SlidableAction(
            onPressed: (context) {
            // Ação de Editar
            Navigator.push(
              context,
              MaterialPageRoute(
                // Passa a transação para a tela de edição
                builder: (context) => EditarTransacaoScreen(
                  transacaoParaEditar: transacao,
                ),
              ),
            ).then((_) {
                _buscarTransacoesParaMes(_mesSelecionado); 
            });
          },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
        ),
        child: ListTile(
          leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          transacao.descricao,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${transacao.hora} - ${transacao.tipo}"),
        trailing: Text(
          currencyFormatter.format(transacao.valor),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ),
      );
    }

  Widget _buildGrupoTransacoes(String data, List<Transacao> transacoes, BuildContext context, ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...transacoes.map((t) => _buildTransacao(t, context)),
        const Divider(),
      ],
    );
  }
  
  @override
  void dispose() {
    tipoController.dispose();
    categoriaController.dispose();
    valorController.dispose();
    descricaoController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final transacoesProvider = Provider.of<TransacoesProvider>(context);

    // Aplica os filtros e a busca
    final transacoesFiltradas = _aplicarFiltros(transacoesProvider.transacoes);

    final Map<String, List<Transacao>> transacoesPorData = {};
    for (var transacao in transacoesFiltradas) {
      if (!transacoesPorData.containsKey(transacao.data)) {
        transacoesPorData[transacao.data] = [];
      }
      transacoesPorData[transacao.data]!.add(transacao);
    }

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCampoBusca(context),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Transações de ${_mesSelecionado.isEmpty ? 'Mês Atual' : DateFormat('MMMM/yyyy', 'pt_BR').format(DateFormat('MM-yyyy').parse(_mesSelecionado))}",
              style:
                  const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            ),
            Expanded(
            child: transacoesPorData.isEmpty
                ? const Center( //Mensagem de "Nenhuma transação encontrada"
                    child: Text(
                        "Nenhuma transação encontrada, tente filtrar as transacoes."),
                  )
                : ListView.builder(
                    itemCount: transacoesPorData.keys.length,
                    itemBuilder: (context, index) {
                      final data = transacoesPorData.keys.elementAt(index);
                      final transacoesDoDia = transacoesPorData[data]!;
                      return _buildGrupoTransacoes(data, transacoesDoDia, context);
                    },
                  ),
            ),
          ],
        ),
    );
  }
}