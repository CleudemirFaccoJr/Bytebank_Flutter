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

<h4>Gráficos</h4>
<p>Para este TC, era necessário integrar gráficos na Dashboard do usuário. Desta forma, utilizei o fl_Chart do PUB.DEV: <a href="https://pub.dev/packages/fl_chart" target="_blank">link aqui</a>
<br/>
Cheguei à conclusão que traria uma implementação mais simples, além de já ter tudo que eu precisava para trazer os dados financeiros. Essas informações inclusive são mistas. Tem coisas que são "heranças" do que usei no Tech Challenge Pt2, e para os meses de Setembro e Outubro são transações novas que inseri, já que o Firebase é o banco de dados que escolhi desde a fase 1.
<br/>
Aqui usamos o AuthProvider, para buscar as transações para o mês selecionado. Dessa forma, o fl_graph monta os gráficos de acordo com o mês que o usuário selecionou. 
<code>
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
</code>
Acima temos o código responsável por buscar as transações para o mês selecionado.

<code>
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
</code>
E aqui temos o código que utiliza a função _buscarTransacoesParaMes para popular o dropdown dos meses que tem transações. Isso é uma coisa interessante, apenas se tivermos transações, o mês é exibido no dropdown. Desta forma evitamos por exemplo de carregar uma lista fixa de meses, que não terão transações.
</p>



