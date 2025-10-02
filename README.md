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

<p>Sumário</p>
<ul>
  <li>Como instalar</li>
  <li><a href="#/providers">Providers</a></li>
</ul>

<h3 id="providers">Providers</h3>
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

<h5>Firebase Storage</h5>
<p>Pro Firebase Storage, eu optei por apenas salvar as fotos dos comprovantes. Eu na fase 2 optei por converter as imagens em BASE64 para poupar espaço no Firenase. Na verdade eu optaria novamente por isso se fosse possível para não gerar possíveis cobranças no futuro. Por questão de tempo, implementei apenas a funcionalidade de salvar os comprovantes, mas daria por exemplo para salvar a foto do usuário (coisa que faço no Minhas Coleções).
A estrutura está bem tranquila. Então para salvar, optei por organizar o Storage da seguinte forma:
fiap---bytebank.firebasestorage.app > comprovantes > [idUsuario] > idTransacao.jpg
<figure>
  <img width="1591" height="898" alt="image" src="https://github.com/user-attachments/assets/4328e13d-39cb-4520-9e8c-5011f6933186" />
  <figcaption>Estrutura do Storage</figcaption>
</figure>

<br/>
Em questão de perfomance, se formor pensar em custo também, faz mais sentido converter a imagem em BASE64 e salva-la no RD. Como nesta fase a gente precisava entregar a integração com o Storage, eu fiz como pedido, mas como a experiência foi positiva na Fase 2, implementarei essa funcionalidade no meu app pessoal, já que economiza um pouco na questão da banda do usuário, processamento, etc...

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

E por fim, como a transação fica no Cloud após uma edição:
<figure>
<img width="1551" height="616" alt="image" src="https://github.com/user-attachments/assets/3afb5090-8155-43e0-899b-01e45caaee64" />
  <figcapion>Transação que foi editada pelo usuário</figcapion>
</figure>
<br/>
</p>



