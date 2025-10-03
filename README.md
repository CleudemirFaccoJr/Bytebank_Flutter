# Bytebank_Flutter
Projeto para a FIAP em Flutter, referente ao Tech Challenge Fase 3
<br/>Desenvolvido por: Cleudemir Facco Junior
<br/><br/>![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)
<br/>
<h4>Sobre a aplicação e escolha da linguagem de programação</h4>
<p>Para o desenvolvimento deste Tech Challenge, eu optei pelo Flutter pelos seguintes pontos:</p>
<ul>
  <li>Tenho um aplicativo atualmente em Java para colecionismo. Minha intenção é migra-lo totalmente para o Flutter;</li>
  <li>Me interessa aprender uma nova linguagem como o Flutter. Já que o React puxa mais para o JavaScript.</li>
</ul>
<p>Esses pontos são puramente individuais, tendo em vista que o React também é uma tecnologia em alta nessa questão do desenvolvimento híbrido.</p>
<p>Referente às tecnologias utilizadas e  conforme foi solicitado no TC3 eu optei por seguir com o Provider. Mesmo tendo outras opções, pelo que entendi, era o mais simples para gerenciamento de estados para a aplicação.
<br/>
Para os providers do aplicativo, temos:
  <ul>
    <li>AuthProvider - este gerencia o estado de autenticação do usuário. Referente aos métodos que temos, vou detalhar parcialmente nesta seção referente aos providers.</li>
    <li>TrancacoesProvider - Essa aqui como o próprio nome tras, ela lida com os estados das transações que rolam no app.</li>
    <li>SaldoProvider - criei este aqui, para gerenciar diretamente o estado do saldo na aplicação;</li>
  </ul>
</p>

<h2>Como instalar a aplicação</h2>
Passo a passo para rodar o projeto Bytebank_Flutter

<h5>Pré-requisitos</h5>

<ul>
  <li>Ter o Git instalado.</li>
  <li>Ter o Flutter instalado e configurado no PATH.</li>
  <li>Ter um editor como VS Code ou Android Studio.</li>
</ul>

<h5>Clonar o repositório</h5>
<code>git clone https://github.com/CleudemirFaccoJr/Bytebank_Flutter.git</code> <br/>

<h5>Entre na pasta do projeto</h5>
<code>cd Bytebank_Flutter/bytebank</code>

<h5>Instalar as dependências</h5>
<code>flutter pub get</code>

<h6>Todas as dependências que eu usei:</h6>
<ul>
  <li>firebase_core: ^4.0.0</li>
  <li>firebase_auth: ^6.0.1</li>
  <li>firebase_database: ^12.0.1</li>
  <li>provider: ^6.1.5+1</li>
  <li>cloud_firestore: ^6.0.1</li>
  <li>intl: ^0.20.2</li>
  <li>mask_text_input_formatter: ^2.9.0</li>
  <li>fl_chart: ^1.1.1</li>
  <li>characters: ^1.4.0</li>
  <li>vector_math: ^2.2.0</li>
  <li>firebase_storage: ^13.0.2</li>
  <li>file_picker: ^10.3.3</li>
  <li>image_picker: ^1.2.0</li>
  <li>flutter_slidable: ^4.0.1</li>
  <li>uuid: ^4.5.1</li>
  <li>flutter_test: sdk: flutter</li>
  <li>flutter_lints: ^6.0.0</li>
</ul>

<h5>Rodar o projeto</h5>
<code>flutter run</code>

<h5>Configurações adicionais</h5>
Se for usar recursos do Firebase, verifique se os arquivos google-services.json (Android) está presentes e configurado corretamente.<br/>
<a href="bytebank/android/app/google-services.json">Arquivo google-services.json</a>

<h3>Providers</h3>
<p>Para gerenciamento do estado da aplicação Flutter, optei pelos providers. Conversando com um colega dev, e seguindo mais ou menos o escopo da aplicação, optei pelo modo mais simples de gerenciamento.
<br/>
Seguindo essa tática, optei por criar o AuthProvider, SaldoProvider e o TransacoesProvider.
</p>
<h5>AuthProvider</h5>
<p>Este aqui, de longe o provider que eu fiquei mais feliz em montar. Como disse mais acima, o meu app Minhas Coleções (feito em JAVA) não tem esse tipo de gerenciamento de estado (falha minha). Como pretendo migrar para o Flutter essa aplicação, foi uma experiência muito interessante gerenciar de modo global a autenticação do usuário.
<br/>
Então o provider de autenticação tem os seguintes métodos:
  <ul>
    <li>_fetchUserNameFromDatabase: esse aqui ele basicamente recupera do Firebase (neste caso o Realtime Database) o idUsuario, e com isso, pega o nome do usuário;</li>
    <li>atualizarSenha: esse método aqui é responsável por atualizar a senha do usuário quando ele insere a senha para alteração;</li>
  </ul>
</p>

 ```flutter
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _userNameFromDatabase = '';

  AuthProvider() {
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    _user = user;
    _userNameFromDatabase = '';

    // Se displayName for nulo ou vazio, busca no Realtime DB
    if (_user != null &&
        (_user!.displayName == null || _user!.displayName!.isEmpty)) {
      await _fetchUserNameFromDatabase();
    }

    notifyListeners();
  });
}

  Future<void> _fetchUserNameFromDatabase() async {
  final uid = _user!.uid;
  final dbRef = FirebaseDatabase.instance.ref();

  try {
    final snapshot = await dbRef.child('contas/$uid/nomeUsuario').get();
    if (snapshot.exists) {
      final nameValue = snapshot.value;
      _userNameFromDatabase = nameValue != null ? nameValue.toString() : '';

      try {
        await _user?.updateDisplayName(_userNameFromDatabase);
        await _user?.reload();
        _user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        debugPrint('Erro ao atualizar displayName: $e');
      }

      notifyListeners(); 
    }
  } catch (e) {
    debugPrint('Erro ao buscar nome do usuário: $e');
  }
}

Future <void> atualizarSenha(String novaSenha) async {
  if (_user != null) {
    try {
      await _user!.updatePassword(novaSenha);
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar senha: $e');
      rethrow;
    }
  }
}


  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String get userName {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    } else if (_userNameFromDatabase != null && _userNameFromDatabase!.isNotEmpty) {
      return _userNameFromDatabase!;
    } else {
      return 'Bytebank';
    }
  }

  String get userId => _user?.uid ?? '';
}
 ```

Estou colocando o AuthProvider na integra aqui, não seria necessário já que é possível visualizar o arquivo. De qualquer forma, eu gostaria aqui de salientar uma funcionalidade que coloca o nome do usuário como Bytebank no Widget caso não tenha nenhum nome de usuário cadastrado. No caso, o AuthProvider foi usado em várias telas, isso ajudou a centralizar funcionalidades como buscar o nome, idUsuario, etc.

Um exemplo do seu uso (o mais simples de todos) é na AppBar:

 ```flutter
@override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final userName = authProvider.userName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.corBytebank,

        automaticallyImplyLeading: false,

        title: Text("Olá - $userName", style: TextStyle(color: Colors.white)),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),

            onPressed: () {
              showDialog(
                context: context,

                builder: (context) => AlertDialog(
                  title: const Text("Sair do App"),

                  content: const Text(
                    "Tem certeza que deseja sair do aplicativo?",
                  ),

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),

                      child: const Text("Cancelar"),

                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.verdeClaro,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        exit(0);
                      },

                      child: const Text("Sair"),

                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
 ```

<h5>SaldoProvider</h5>
<p>O SaldoProvider é um provider baseado na arquitetura ChangeNotifier do Flutter, responsável por gerenciar e sincronizar o saldo da conta do usuário com o Realtime Database do Firebase.<br/>
Ele encapsula toda a lógica de persistência e atualização do saldo, garantindo que o valor exibido na interface do usuário seja sempre consistente com o que está armazenado no banco de dados.</p>
<p>O saldo é mantido de forma assíncrona no Firebase Realtime Database sob o nó contas/{userId}/saldo.<br/>
Acesso Rápido: A propriedade _saldo armazena o valor localmente. O getter saldo o expõe para widgets (com um fallback seguro para 0.0).<br/>
Inicialização: O método carregarSaldo() é responsável por buscar o saldo inicial do usuário no Firebase, tratar o caso de usuários deslogados (saldo 0.0), e garantir a conversão correta do valor (num para double), definindo 0.0 se o nó não existir ou se o formato estiver incorreto.

```flutter
Future<void> carregarSaldo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        //GARANTE QUE O SALDO É ZERADO SE NENHUM USUÁRIO ESTIVER LOGADO
        _saldo = 0.0;
        notifyListeners();
        return;
      }

      // CAMINHO EXCLUSIVO PARA O USUÁRIO LOGADO
      final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final value = snapshot.value;

        // TENTA CONVERTER DIRETAMENTE O VALOR DO NÓ '/saldo' PARA UM NÚMERO
        if (value is num) {
          _saldo = value.toDouble();
        } else {
          // Se o valor não for um número (estrutura incorreta), assume 0.0
          _saldo = 0.0;
        }
        // Se o snapshot não existir, significa que é o primeiro acesso (saldo = 0)
      } else {
        _saldo = 0.0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar saldo: $e");
      // Em caso de erro, define o saldo como 0.0 para evitar saldos incorretos
      _saldo = 0.0;
      notifyListeners();
    }
  }
```
</p>
<p>O método atualizarSaldo() é chamado sempre que uma nova transação é criada (depósito, transferência, pagamento, etc.).<br/>
  Nesse ponto, criei uma lógica que determina o impacto da transação:
  <ul>
    <li>Crédito (Soma): Se o tipoTransacao for 'deposito' ou 'investimento'.</li>
    <li>Débito (Subtrai): Para todos os outros tipos (Transferência, Pagamento, etc.).</li>
  </ul><br/>
 O novo saldo é salvo no Firebase (ref.set(novoSaldo)).<br/>
 Após a atualização, chama notifyListeners() para reconstruir os widgets dependentes.<br/>
 Garante que a lista de transações (gerenciada pelo TransacoesProvider) também seja recarregada (buscarTransacoes()) para refletir a nova entrada e o saldo atualizado.<br/>

```flutter
Future<void> atualizarSaldo(
    BuildContext context,
    double valor,
    String tipoTransacao,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");

    double novoSaldo = _saldo ?? 0.0;

    // Determina se a transação é um crédito (soma) ou débito (subtrai)
    if (tipoTransacao == 'deposito' || tipoTransacao == 'investimento') {
      novoSaldo += valor;
    } else {
      //Transferência, Pagamento, etc.
      novoSaldo -= valor;
    }

    try {
      await ref.set(novoSaldo);
      _saldo = novoSaldo;
      notifyListeners();

      await Provider.of<TransacoesProvider>(
        context,
        listen: false,
      ).buscarTransacoes(user.uid);
    } catch (e) {
      debugPrint("Erro ao atualizar saldo: $e");
      rethrow;
    }
  }
```
</p>

<p>Por fim temos a lógica mais robusta para manter a integridade do saldo quando uma transação existente é modificada (valor ou tipo), que é o ajuste do saldo após a edição da transação.<br/>
A estratégia implementada é uma operação de "Reverter e Aplicar":
<ol>
  <li>Reverter Original: O código primeiro inverte o impacto da transação original no saldo atual (ex.: se era um depósito de R$50, subtrai R$50).</li>
  <li>Aplicar Novo Impacto: Em seguida, aplica-se o impacto do novo valor e tipo da transação (ex.: se agora é uma transferência de R$100, subtrai R$100).</li>
  <li>Atualização: O novoSaldo resultante é então persistido no Firebase e a interface é atualizada via notifyListeners().</li>
</ol>
<br/>
Esta abordagem garante que o saldo seja recalculado corretamente, independentemente de o usuário ter alterado apenas o valor, apenas o tipo, ou ambos.

```flutter
Future<void> ajustarSaldoAposEdicao(
    BuildContext context,
    double valorOriginal,
    String tipoOriginal,
    double novoValor,
    String novoTipo,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("contas/${user.uid}/saldo");

    double novoSaldo = _saldo ?? 0.0;

    //Reverter o impacto da transação original
    // Crédito original (soma)
    if (tipoOriginal == 'deposito' || tipoOriginal == 'investimento') {
      novoSaldo -= valorOriginal;
    } else {
      // Débito original (subtrai)
      novoSaldo += valorOriginal;
    }

    //Aplicar o novo impacto da transação
    // Novo Crédito (soma)
    if (novoTipo == 'deposito' || novoTipo == 'investimento') {
      novoSaldo += novoValor;
    } else {
      // Novo Débito (subtrai)
      novoSaldo -= novoValor;
    }

    try {
      await ref.set(novoSaldo);
      _saldo = novoSaldo;
      notifyListeners();

      // Atualiza a lista de transações para refletir as mudanças
      await Provider.of<TransacoesProvider>(
        context,
        listen: false,
      ).buscarTransacoes(user.uid);
    } catch (e) {
      debugPrint("Erro ao ajustar saldo após edição: $e");
      rethrow;
    }
  }
```
</p>

<h5>TransacoesProvider</h5>
<p>O TransacoesProvider é o provider central responsável por toda a gestão do histórico de movimentações financeiras do usuário. Ele lida com a busca, a criação e a sincronização das transações em dois serviços de banco de dados do Firebase: o Realtime Database (RTDB) e o Cloud Firestore.<br/>
Mantém a lista de transações (_transacoes) e a lista dos meses que possuem movimentação (_mesesComTransacoes) em memória.<br/>
  
```flutter
  Future<void> fetchMesesComTransacoes() async {
    final dbRef = FirebaseDatabase.instance.ref("transacoes");
    final snapshot = await dbRef.get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic>? dados = snapshot.value as Map?;
      if (dados != null) {
        _mesesComTransacoes = dados.keys.cast<String>().toList();
        _mesesComTransacoes.sort();
      }
    } else {
      _mesesComTransacoes = [];
    }
    notifyListeners();
  }
```
<br/>
Ai tem a questão de salvar tanto no Realtime Database como no Cloud Firestore. Abordei isso mais abaixo na parte de Cloud mesmo...
Temos a parte referente à Busca e Filtragem de Transações <code>buscarTransacoes()</code>:<br/>
Este método é responsável por carregar as transações de um período específico.
<ul>
  <li>Filtro Opcional por Mês/Ano: O método aceita um parâmetro mesAno opcional (MM-yyyy). Se omitido, ele assume o mês atual.</li>
  <li>Estrutura de Busca Otimizada: A busca é feita no RTDB seguindo a estrutura: transacoes/{mesAno}/{dia}/{userId}/{idTransacao}. Essa organização hierárquica permite o carregamento rápido de grandes volumes de dados mensais sem percorrer o histórico completo.</li>
  <li>Mapeamento Manual: Os dados brutos do Firebase (Map<dynamic, dynamic>) são manualmente mapeados para o Model Transacao, garantindo a tipagem correta (como a conversão de num para double no campo valor).</li>
  <li>Identificação do Usuário: Dentro de cada nó de dia, a lógica filtra especificamente as transações pertencentes ao userId logado.</li>
</ul>
<br/>
    
```flutter
Future<void> buscarTransacoes(String userId, {String? mesAno}) async {
    _transacoes = [];
  _transacoes.clear();

  final dbRef = FirebaseDatabase.instance.ref("transacoes");
   

  final mesAtual = mesAno ??
      "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";

  final snapshot = await dbRef.child(mesAtual).get();

  if (snapshot.exists) {
    debugPrint("Transações encontradas para $mesAtual");

    final Map<dynamic, dynamic>? dadosDoMes = snapshot.value as Map?;
    if (dadosDoMes != null) {
      
      dadosDoMes.forEach((dia, dadosDoDia) {
        
        if (dadosDoDia is Map && dadosDoDia.containsKey(userId)) {
          final Map<dynamic, dynamic> transacoesMap = dadosDoDia[userId];
          
          transacoesMap.forEach((id, dadosDaTransacao) {
            
            // CONSTRUÇÃO MANUAL DO OBJETO TRANSACAO USANDO PLACEHOLDERS
            final transacao = Transacao(
              tipo: dadosDaTransacao['tipoTransacao'] as String,
              valor: (dadosDaTransacao['valor'] as num).toDouble(),
              descricao: dadosDaTransacao['descricao'] as String,
              categoria: dadosDaTransacao['categoria'] as String,
              anexoUrl: dadosDaTransacao['anexoUrl'] as String?,
              idTransacao: id,
              
              idconta: userId,
              saldoAnterior: 0.0,
              saldoFinal: 0.0,
            );
            
            _transacoes.add(transacao);
          });
        }
      });
      
      if (_transacoes.isNotEmpty) {
        debugPrint("Total de transações carregadas: ${_transacoes.length}");
        for (var t in _transacoes) {
          debugPrint("ID: ${t.idTransacao}, Tipo: ${t.tipo}, Valor: ${t.valor}, Data: ${t.data}, Categoria: ${t.categoria}");
        }
      } else {
        debugPrint("Nenhuma transação encontrada para este usuário em $mesAtual");
      }
    }
  } else {
    debugPrint("Nenhuma transação encontrada no Firebase para $mesAtual");
  }

  notifyListeners();
}
```
<br/>
Adicionar Transação e Comprovante - adicionarTransacao()<br/>
Este método coordena o salvamento da transação e seu anexo em três etapas:
<ol>
  <li>Upload do Comprovante (Firebase Storage):
    <ul>
      <li>Se um arquivo de comprovante (File?) for fornecido, ele é enviado para o Firebase Storage no caminho otimizado: comprovantes/{userId}/{idTransacao}.</li>
      <li>A URL de download (anexoUrl) é obtida e incorporada aos dados da transação.</li>
    </ul>
  </li>
  <li>Salvar no Realtime Database (RTDB):
    <ul>
      <li>A transação é salva na estrutura hierárquica por data (mesAno e dia) para busca rápida.</li>
    </ul>
  </li>
  <li>Replicação para o Cloud Firestore (Firestore):
    <ul>
      <li>Os dados da transação, juntamente com um timestamp unificado (dataHora), são replicados em uma coleção por usuário: usuarios/{userId}/transacoes/{idTransacao}.</li>
      <li><i>Esta replicação visa habilitar consultas avançadas de histórico e ordenação que são mais eficientes no Firestore.</i></li>
    </ul>
  </li>
  <li>Atualização de Saldo: Por fim, o método atualiza o saldo final do usuário no nó contas/{userId}/saldo do RTDB, garantindo que o saldo da conta reflita a nova movimentação.</li>
</ol>
</p>


<h4>Gráficos</h4>
<p>Para este TC, era necessário integrar gráficos na Dashboard do usuário. Desta forma, utilizei o fl_Chart do PUB.DEV: <a href="https://pub.dev/packages/fl_chart" target="_blank">link aqui</a>
<br/>
Cheguei à conclusão que traria uma implementação mais simples, além de já ter tudo que eu precisava para trazer os dados financeiros. Essas informações inclusive são mistas. Tem coisas que são "heranças" do que usei no Tech Challenge Pt2, e para os meses de Setembro e Outubro são transações novas que inseri, já que o Firebase é o banco de dados que escolhi desde a fase 1.
<br/>
Aqui usamos o AuthProvider, para buscar as transações para o mês selecionado. Dessa forma, o fl_graph monta os gráficos de acordo com o mês que o usuário selecionou. 

  ```flutter
  // Função para chamar o provider para buscar as transações do mês selecionado
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
```
Acima temos o código responsável por buscar as transações para o mês selecionado.

```flutter
  Widget _buildDropdownRow(BuildContext context) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              Text(
                  'Gráficos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeClaro,
                  ),
              ),
              DropdownButton<String>(
                  value: _mesSelecionado,
                  hint: const Text('Selecione o Mês'),
                  items: _mesesDisponiveisKeys.map((mesKey) {
                      return DropdownMenuItem(
                          value: mesKey, 
                          child: Text(_formatMesKey(mesKey)), 
                      );
                  }).toList(),
                  onChanged: (novoMesKey) {
                      if (novoMesKey != null) {
                          setState(() {
                              _mesSelecionado = novoMesKey;
                          });
                          _buscarTransacoesParaMes(novoMesKey);
                      }
                  },
              ),
          ],
      );
  }
```
E aqui temos o código que utiliza a função _buscarTransacoesParaMes para popular o dropdown dos meses que tem transações. Isso é uma coisa interessante, apenas se tivermos transações, o mês é exibido no dropdown. Desta forma evitamos por exemplo de carregar uma lista fixa de meses, que não terão transações.
</p>
<h4>Firebase</h4>
<p>Desde que iniciei a pós graduação optei por seguir com o Firebase por conta de já estar acostumado com este banco de dados. Então, basicamente nada mudou da Fase 1 para cá. A unica diferença é a utilização do JSON que o próprio Firebase fornece para utilizar em aplicações Flutter.<br/>
Então, como solicitado estou usando:
<ul>
  <li>Realtime Database: Para armazenar as informações referentes à transações;</li>
  <li>Authentication: Para a autenticação do usuário. Optei por não salvar mais nada no authenticator além da email e senha, por questão de praticidade mesmo.</li>
  <li>Firebase Storage: usado apenas para salvar os comprovantes das transações. Aqui implementei uma lógica para literalmente apenas SUBSTITUIR o comprovanete quando o usuário edita uma transação.</li>
  <li>Firebase Cloud: </li>
</ul>

<h5>Realtime Database</h5>
<p>Para o Realtime Database, apenas 1 coisa foi modificada em relação à versão da Fase 2. No caso, foi somente como o Saldo era salvo. Anteriormente ele ficava salvo numa estrutura como: saldo > saldo.
<br/>
Porém aqui pra Fase 3 eu consegui modificar como isso é salvo, e ele fica finalmente como: saldo > [ValordoSaldo].
<br/>
Isso facilitou muito na hora de criar o SaldoProvider, uma vez que não tive que ficar ajustando o caminho do valor a ser encontrado pelo provider. Além disso, para manipular as transações também foi mais simples.
<br/>
<figure>
  <img width="1236" height="446" alt="image" src="https://github.com/user-attachments/assets/1c77ffee-8d6d-4b3c-be86-ff07023e73a7" />
  <figcaption>Estrutura de transações no RD. Neste exemplo, não temos um histórico de alterações.</figcaption>
</figure>

</p>

<h5>Authentication</h5>
<p>Nesta etapa, não mudei absolutamente nada no Authentication. Como disse mais acima, estou usando este mesmo banco desde a Fase 1 e pretendo ir com ele até o fim da Pós Graduação (ao término vou dropar o banco). Então apenas à titulo de curiosidade, vou inserir aqui uma imagem de como está ordenado o Authentication</p>

<figure>
   <img width="1593" height="903" alt="image" src="https://github.com/user-attachments/assets/c61a7c8d-128f-4aed-bef1-ffeea8634d91" />
   <figcaption>A imagem acima mostra os usuários cadastrados no Authentication. Percebe-se que temos usuários ali cadastrados em Abril</figcaption>
</figure>
<br/>
Então no caso, eu novamente mantive o que pensei nas fases anteriores para os Tech Challenge. Quando temos uma alteração salvamos um histórico das transações.
<br/>
<figure>
  <img width="1234" height="493" alt="image" src="https://github.com/user-attachments/assets/5598b038-376b-4429-be2b-92b1832f3b9c" />
  <figcaption>Exemplo de transação que possui um histórico de alterações</figcaption>
</figure>
<br/>
Como comentei mais acima, não usei o Authentication para salvar dados do usuário, isso fica salvo no RD na parte de Contas:

<figure>
  <img width="1140" height="320" alt="image" src="https://github.com/user-attachments/assets/1621a3b2-a029-4783-b0df-fe3e6723e969" />
  <figcaption>Exemplo de conta cadastrada, com as informações do usuário</figcaption>
</figure>
<br/>

<h5>Firebase Storage</h5>
<p>Pro Firebase Storage, eu optei por apenas salvar as fotos dos comprovantes. Eu na fase 2 optei por converter as imagens em BASE64 para poupar espaço no Firenase. Na verdade eu optaria novamente por isso se fosse possível para não gerar possíveis cobranças no futuro. Por questão de tempo, implementei apenas a funcionalidade de salvar os comprovantes, mas daria por exemplo para salvar a foto do usuário (coisa que faço no Minhas Coleções).
A estrutura está bem tranquila. Então para salvar, optei por organizar o Storage da seguinte forma:
fiap---bytebank.firebasestorage.app > comprovantes > [idUsuario] > idTransacao.jpg
<figure>
  <img width="1591" height="898" alt="image" src="https://github.com/user-attachments/assets/4328e13d-39cb-4520-9e8c-5011f6933186" />
  <figcaption>Estrutura do Storage</figcaption>
</figure>

<br/>
Em questão de perfomance, se formos pensar em custo também, faz mais sentido converter a imagem em BASE64 e salva-la no RD. Como nesta fase a gente precisava entregar a integração com o Storage, eu fiz como pedido, mas como a experiência foi positiva na Fase 2, implementarei essa funcionalidade no meu app pessoal, já que economiza um pouco na questão da banda do usuário, processamento, etc...

Dando sequencia no que foi solicitado, estou também aqui inserindo a funcionalidade que atualiza a transação, e sobreescreve o comprovante anterior:

```flutter
Future<void> atualizarTransacao(
  // Dados da transação antes da edição
  Transacao transacaoOriginal, 
  // Arquivo do novo comprovante (se selecionado)
  File? novoComprovante, 
  // Se o usuário marcou para remover o comprovante que já existia
  bool removerComprovanteAtual
) async {
  if (idTransacao == null) {
    throw Exception("ID da transação é nulo. Não é possível atualizar.");
  }

  // Usar data e idconta originais para localizar o nó no Firebase
  final mesVigente = DateFormat('MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(transacaoOriginal.data));
  final diaOriginal = transacaoOriginal.data;
  final id = idTransacao!;
  String? novoAnexoUrl = anexoUrl;

  try {
    //Lógica de Comprovante
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('comprovantes')
        .child(idconta)
        .child('$id.jpg');

    if (removerComprovanteAtual && transacaoOriginal.anexoUrl != null) {
      // Excluir comprovante existente no Storage
      await storageRef.delete();
      novoAnexoUrl = null;
      debugPrint("Comprovante anterior removido do Storage.");
    } else if (novoComprovante != null) {
      // Substituir ou adicionar novo comprovante
      final uploadTask = storageRef.putFile(novoComprovante);
      final snapshot = await uploadTask;
      novoAnexoUrl = await snapshot.ref.getDownloadURL();
      debugPrint("Comprovante atualizado/adicionado. URL: $novoAnexoUrl");
    } else {
      // Mantém o anexoUrl original se não houve nem remoção nem novo upload
      novoAnexoUrl = transacaoOriginal.anexoUrl;
    }

    //Preparar Dados de Histórico
    final historicoAtual = transacaoOriginal.historico ?? [];
    
    //Registrar o estado anterior da transação
    final Map<String, dynamic> estadoAnterior = {
        'timestamp': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
        'acao': 'Edição da Transação',
        'dadosAntigos': {
            'tipoTransacao': transacaoOriginal.tipo,
            'valor': transacaoOriginal.valor,
            'descricao': transacaoOriginal.descricao,
            'categoria': transacaoOriginal.categoria,
            'anexoUrl': transacaoOriginal.anexoUrl,
            'status': transacaoOriginal.status,
        },
    };
    historicoAtual.add(estadoAnterior);

    //Atualizar dados no Realtime Database
    final transacaoRef = FirebaseDatabase.instance.ref()
        .child('transacoes')
        .child(mesVigente)
        .child(diaOriginal.substring(0, 2))
        .child(idconta)
        .child(id); // ID da transação existente

    // Usar a data original da transação. O status é 'Editada'.
    final Map<String, dynamic> dadosParaAtualizar = {
      'tipoTransacao': tipo,
      'valor': valor,
      'descricao': descricao,
      'categoria': categoria,
      'anexoUrl': novoAnexoUrl,
      'status': 'Editada',
      'saldo': saldoFinal,
      'historico': historicoAtual,
    };

    await transacaoRef.update(dadosParaAtualizar);
    
    //Recálculo de Saldo
    
    debugPrint("Transação, anexo e histórico atualizados com sucesso.");
  } on FirebaseException catch (e) {
    debugPrint("Erro do Firebase ao atualizar transação: ${e.message}");
    throw Exception("Erro ao atualizar a transação. Tente novamente.");
  } catch (error) {
    debugPrint("Erro inesperado ao atualizar transação: $error");
    throw Exception("Erro inesperado ao atualizar a transação.");
  }
}
```

Coloquei o máximo de comentário, até pensando se em algum momento alguém quiser mexer neste código, temos separadamente o que cada parte faz no código.
Outro ponto bacana, é que ao invés de usar "print" eu optei por usar debugPrint. Dessa forma o VSCode não fica reclamando de usar prints em um ambiente de produção. Pelo que eu entendi nas minhas pesquisas, isso não influencia em nada para o usuário, mas fica melhor pra quem está desenvolvendo que não fica com os alerts do VSCode o tempo todo "incomodando".
</p>
<h5>Firebase Cloud</h5>
<p>O Firebase Cloud foi integrado bem ao fim do projeto, faltando dias para funcionar. Não me atentei nesta parte e desenvolvi TUDO usando apenas o Realtime Database. Para contornar isso, e implementar a necessidade do TC, optei por fazer uma duplicação. Então quando uma transação é salva, ela salva tanto no RD quanto no Cloud.
<br/>
Achei bem esquisita a implementação, contudo realizei a mesma a fim de entregar o TC, mas não optaria por isso caso fizesse um outro projeto (o que não fiz no Minhas Coleções. Uso apenas o Realtime Database e funciona muito bem)</p>

<figure>
  <img width="1545" height="611" alt="image" src="https://github.com/user-attachments/assets/40429d00-7cd2-4a81-af64-1690e23560d8" />
  <figcapion>Cloud Firestore com os dados das transações</figcapion>
</figure>
<br/>

Toda transação que é CRIADA já salva tanto no Realtime Database, quanto no Cloud. E como tem algumas transações que já estavam previamente criadas, pensei que seria um exercícío interessante refazer o processo de salvar no Cloud.<br/>
Ou seja, se uma transação que não está no cloud é editada, ela após a edição é salva também no cloud. Também atualiza o dado no Database só por desencargo. Abaixo, temos ai como está o Cloud com as transações:

<figure>
  <img width="1549" height="615" alt="image" src="https://github.com/user-attachments/assets/c24140f4-642f-4bc8-940b-aed63fc652ff" />
  <figcapion>Cloud Firestore com as transações de um usuário</figcapion>
</figure>
<br/>
Aqui o trecho do código responsável por "Duplicar" a transação pro Cloud

```flutter
//Duplicando pro Cloud
    try {
        final firestoreDocRef = FirebaseFirestore.instance
            .collection('usuarios') 
            .doc(idconta) // idconta é o userId, usado como chave do usuário
            .collection('transacoes')
            .doc(idTransacao); // idTransacao é o ID do documento

        // Prepara o mapa para o Firestore
        final firestoreUpdateMap = {
            ...dadosParaAtualizar, 
            // Adiciona/Atualiza o campo unificado de data/hora (Timestamp)
            'dataHora': DateFormat('dd-MM-yyyy HH:mm:ss').parse(
                '$data $hora:00'), // Cria um DateTime a partir dos campos existentes
        };

        // 1. Verifica a existência do documento
        final docSnapshot = await firestoreDocRef.get();
        
        if (!docSnapshot.exists) {
            // SE NÃO EXISTIR, usa set() para CADASTRAR/CRIAR
            await firestoreDocRef.set(firestoreUpdateMap);
            debugPrint("CFS: Transação cadastrada no Firestore.");
        } else {
            // SE EXISTIR, usa update() para ATUALIZAR
            await firestoreDocRef.update(firestoreUpdateMap);
            debugPrint("CFS: Transação atualizada no Firestore.");
        }

    } catch (e) {
        debugPrint("AVISO: Falha ao atualizar transação no Firestore: $e");
        // Loga o erro do Firestore, mas não impede o fluxo do RTDB
    }
```

E por fim, como a transação fica no Cloud após uma edição:
<figure>
<img width="1551" height="616" alt="image" src="https://github.com/user-attachments/assets/3afb5090-8155-43e0-899b-01e45caaee64" />
  <figcapion>Transação que foi editada pelo usuário</figcapion>
</figure>
<br/>
</p>

<h4>Widgets</h4>
<p>Para o Tech Challenge fase 3, optei por montar alguns widgets que facilitassem na hora da modularização do sistema. Claro, na próxima fase, pretendo criar mais widgets para que a manutenção flua de forma mais dinâmica do que agora. Não que esteja ruim, mas creio que algumas coisas possam melhorar, além de melhorar a arquitetura do projeto.<br/>
Então montei os seguintes Widgets:
<ul>
  <li>Acesso rápido: listagem de funcionalidades que temos nas telas. Por exemplo extrato;</li>
  <li>Gráficos: montei todos os gráficos aqui, assim fica mais fácil de carregar isso na Dashboard Screen, além de reduzir um pouco a quantidade de caracteres na tela;</li>
  <li>Navigation Bar: barra inferior do app. Trás ali alguns atalhos pra outras telas.</li>
  <li>Saldo: Esse widget é responsável por montar o pedaço de saldo que aparece no Dashboard. Ele faz apenas isso. Então ele utiliza ai o SaldoProvider, pra montar especificamente isso no dashboard.</li>
</ul>
<br/>
Os widgets foram parte fundamental do projeto no quesito de tempo. Creio que pra próxima etapa, como temos que focar em arquitetura, eu pretendo modularizar a aplicação de modo que os pedaços mais relevantes sejam widgets. Infelizmente por conta de tempo, não consegui quebrar em mais pedaços.
</p>

<h4>Screens</h4>
<p>As screens compoem o app de modo geral. Aqui as mais relevantes na minha opinião:
<ul>
  <li>Dashboard Screen - tela principal do aplicativo. Ela é toda basicamente montada usando os widgets de Saldo, acesso rápido e gráficos. A unica que tem o Floating Action Button que adiciona transações. Acredito que pro fluxo do usuário faça mais sentido ali, que em outras telas.</li>
  <li>Transações Screen - o nome da tela foi meio infeliz, ela deveria ser "Cadastro Screen", mas achei melhor prosseguir assim, ela é responsável por cadastrar todas as transações do sistena.</li>
  <li>Editar Transações - é a tela responsável por carregar os dados da transação à ser editada. Ele foi montada de forma simples, apenas carrega os dados, e permite que o usuário edite. Valida se os campos não estão vazios. Então nela, assim como na de Transações (cadastro), é possível fazer o upload de um anexo. A grande diferença na minha opinião é que nela o usuário consegue visualizar o anexo anterior, exclui-lo e subir um novo por exemplo</li>
  <li>Extrato Screen - Nessa tela a gente consegue visualizar todas as transações que foram cadastradas pelo usuário. Ela também tem o filtro e o campo de busca. Aqui nessa tela a gente tem a busca no banco de dados. Então quando o usuario preenche um texto no campo Busca, ele já atualiza a exibição pra trazer os resultados que estejam compreendidos nessa View. Temos também os filtros avançados. Nesse caso implementei algumas coisas bacanas, como por exemplo os <code>FilterChip</code>. Eles são carregados dinamicamente de acordo com as categorias que estão cadastradas na tela.</li>

  ```flutter
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
  ```
</ul>
</p>

<h4>Lições aprendidas e melhorias</h4>
<p>O Flutter e o Dart me mostraram MUITAS vantagens em relação ao JAVA no desenvolvimento Mobile.<br/>
Acredito que seja uma tecnologia muito simples, de utilizar, na hora de construir as Views por exemplo, é um processo bem mais simples que no JAVA por exemplo, validações, etc. Além do fato de você precisar apenas do Visual Studio pro desenvolvimento, que no fim das contas é um excelente editor de texto, tem muitas coisas complementares que ajudam no dia a dia. </p>

<h6>Melhorias</h6>
<p>Definitivamente vou ajustar diversas coisas pra próxima eetapa do Tech Challenge.<br/>
Uma delas é fazer com que o model transação fique mais limpo e não tenha métodos que devem estar no provider.<br/>
Outro ponto também é a parte de criar outros componentes, como por exemplo o investimento, mesmo que de forma mais simples, pra que o usuário veja os valores investidos, de repente pensar num Provider separado pra emular os rendimentos das aplicações, de repente também um campo de "meta" que ele possa setar quanto ele quer investir e quanto tempo vai levar pra chegar lá colocando o mesmo valor todo mês.
<br/>
Pra próxima fase, como não é obrigatório o uso do Cloud, essa parte será removida do código posteriormente, juntamente com o uso do Storage. Vou fazer com que as imagens sejam convertidas em BASE64 e salvar tudo no Realtime Database. Dessa forma, o aplicativo fica mais simples e não tem métodos repetidos, ou mesmo o duplo salvamento.
<br/>
Por fim, o foco na proxíma fase, como citei várias vezes aqui, é o de Arquitetura, vou tentar separar mais os componentes, de repente criar outros providers. Além de trabalhar no lazy loading e implementar mais retornos para o usuário, como por exemplo as mensagens de que a transação está sendo salva, ou atualizada. Eu implementei isso apenas em uma view, e sei que o correto é que o usuário tenha um retorno mais visual, pra que ele tenha uma navegação mais fluída.
</p>