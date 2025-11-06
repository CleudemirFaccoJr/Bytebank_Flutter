# Bytebank
O projeto está sendo desenvolvido utiizando Flutter.
Esta é a branch oficial para o Tech Challenge Fase 4


####State Management Patterns
Para o Tech Challenge fase 4, foi solicitado que houvesse a implementação de SMP avançados. Como o meu projeto está todo focado em flutter, eu analisei e optei por utilizar o Riverpod para fazer isso.

<a href="https://pub.dev/packages/riverpod/install">Riverpod</a>

Pelo que pesquisei, trata-se de um conceito mais minimalista e simplificado. Por conta de tempo e escopo do projeto optei por esta tecnologia.

####Clean Architecture
Seguindo as recomendações do Flutter, ajustei a hierarquia do projeto para contemplar os conceitos de Clean Architecture. Não foi tão trabalhoso como pensei, uma vez que o próprio Visual Studio Code, refatora o caminho dos objetos automaticamente.
Então, a hierarquia ficou basicamente desta forma:

lib/
├───features/
│   ├───auth/
│   │   ├───data/
│   │   │   models/
│   │   │       usuario_model.dart
│   │   └───presentation/
│   │       providers/
│   │           auth_provider.dart
│   │       screens/
│   │           login_screen.dart
│   │           register_screen.dart
│   │           esquecisenha_screen.dart
│   │           profile_screen.dart
│   ├───saldo/
│   │   └───presentation/
│   │       providers/
│   │           saldo_provider.dart
│   │       screens/
│   │           dashboard_screen.dart
│   └───transacoes/
│       ├───data/
│       │   models/
│       │       transacao_model.dart
│       └───presentation/
│           providers/
│               transacoes_provider.dart
│           screens/
│               editartransacao_screen.dart
│               extrato_screen.dart
│               transacoes_screen.dart
├───shared/
│   └───widgets/
│       acessorapido.dart
│       graficos.dart
│       navigationbar.dart
│       saldo.dart

####Segurança
Conforme solicitado para o TC4, era necessário implementar uma tecnologia que trouxesse uma camada à mais de segurança para o aplicativo. Desta forma optei por utilizar o: [NOME DA BIBLIOTECA DE CRIPTOGRAFIA].
