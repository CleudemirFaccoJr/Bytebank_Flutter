# Bytebank_Flutter
Projeto para a FIAP em Flutter, referente ao Tech Challenge Fase 3
<br/>Desenvolvido por: Cleudemir Facco Junior
<br/><br/>![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)
<br/>
#### Sobre a aplicação e escolha da linguagem de programação
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

###Providers
<p>Para gerenciamento do estado da aplicação Flutter, optei pelos providers. Conversando com um colega dev, e seguindo mais ou menos o escopo da aplicação, optei pelo modo mais simples de gerenciamento.
<br/>
Seguindo essa tática, optei por criar o AuthProvider, SaldoProvider e o TransacoesProvider.
</p>
#####AuthProvider
<p>Este aqui, de longe o provider que eu fiquei mais feliz em montar. Como disse mais acima, o meu app Minhas Coleções (feito em JAVA) não tem esse tipo de gerenciamento de estado (falha minha). Como pretendo migrar para o Flutter essa aplicação, foi uma experiência muito interessante gerenciar de modo global a autenticação do usuário.
<br/>
Então o provider de autenticação tem os seguintes métodos:
  <ul>
    <li>_fetchUserNameFromDatabase: esse aqui ele basicamente recupera do Firebase (neste caso o Realtime Database) o idUsuario, e com isso, pega o nome do usuário;</li>
    <li>atualizarSenha: esse método aqui é responsável por atualizar a senha do usuário quando ele insere a senha para alteração;</li>
  </ul>
</p>




