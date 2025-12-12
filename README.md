# Bytebank
O projeto está sendo desenvolvido utiizando Flutter.
Esta é a branch oficial para o Tech Challenge Fase 4


#### State Management Patterns
Para o Tech Challenge fase 4, foi solicitado que houvesse a implementação de SMP avançados. Como o meu projeto está todo focado em flutter, eu analisei e optei por utilizar o Riverpod para fazer isso.

<a href="https://pub.dev/packages/riverpod/install">Riverpod</a>

Pelo que pesquisei, trata-se de um conceito mais minimalista e simplificado. Por conta de tempo e escopo do projeto optei por esta tecnologia.

Então, um exemplo do uso do Riverpod para a nova necessidade do Tech Challenge é o usuarioprovider.dart:

 ```flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bytebank/features/auth/data/models/usuario.dart';
import 'package:riverpod/riverpod.dart';

final usuarioProvider = FutureProvider<Usuario>((ref) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final snapshot = await FirebaseDatabase.instance
      .ref("usuarios/$uid")
      .get();

  return Usuario.fromMap(snapshot.value as Map);
});
  ```

#### Clean Architecture
Seguindo as recomendações do Flutter, ajustei a hierarquia do projeto para contemplar os conceitos de Clean Architecture. Não foi tão trabalhoso como pensei, uma vez que o próprio Visual Studio Code, refatora o caminho dos objetos automaticamente.
Então, a hierarquia ficou basicamente desta forma:

```
lib/
├───features/
│   ├───auth/
│   │   ├───data/
│   │   │   models/
│   │   │       usuario.dart
│   │   └───presentation/
│   │       providers/
│   │           authprovider.dart
│   │           usuarioprovider.dart
│   │       screens/
│   │           login_screen.dart
│   │           register_screen.dart
│   │           esquecisenha_screen.dart
│   │           profile_screen.dart
│   ├───saldo/
│       ├───data/
│       │   models/
│       │       saldo.dart
│   │   └───presentation/
│   │       providers/
│   │           saldo_provider.dart
│   │       screens/
│   │           dashboard_screen.dart
│   └───transacoes/
│       ├───data/
│       │   models/
│       │       transacao_historico.dart
│       │       transacao.dart
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
```

Seguindo então os padrões de Clean Architecture, eu estruturei os models para cada tipo de Entidade da aplicação.
Então temos de fato as seguintes entidades:

```
Usuario
Transacao
Saldo
```

Desta forma, os conceitos estão sendo seguidos, e as Entidades podem ser reutilizadas em diversas áreas do aplicativo.

#### Segurança
Conforme solicitado para o TC4, era necessário implementar uma tecnologia que trouxesse uma camada à mais de segurança para o aplicativo. Desta forma optei por utilizar o: [NOME DA BIBLIOTECA DE CRIPTOGRAFIA].

#### Cache  
Para atender as expectativas do TC4, optei pelo uso do Flutter_Cache_Manager.
<a href="https://pub.dev/packages/flutter_cache_manager">Flutter_Cache_Manager</a>