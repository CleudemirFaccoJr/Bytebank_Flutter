# Bytebank
O projeto está sendo desenvolvido utiizando Flutter.
Esta é a branch oficial para o Tech Challenge Fase 4

Esta versão aplicou refatorações e melhorias importantes na organização do código, gerenciamento de estado, responsividade e segurança de forma incremental. A base já está modularizada visualmente e integrada ao Firebase; várias práticas sugeridas (lazy loading, feedback de carregamento, uso de streams) foram adotadas. Ainda há espaço para evolução para uma Clean Architecture completa, cache encriptado e state management reativo mais avançado.


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
│   │   │       usuariomodel.dart
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
│       │       saldomodel.dart
│       └───presentation/
│       │       providers/
│       │           saldo_provider.dart
│       │   screens/
│               dashboard_screen.dart
│   └───transacoes/
│       ├───data/
│       │   models/
│       │       transacao_historico.dart
│       │       transacaomodel.dart
│       └───presentation/
│           providers/
│               cadastrar_transacao_notifier.dart  
│               transacoes_provider.dart
│           screens/
│               editartransacao_screen.dart
│               extrato_screen.dart
│               cadastrartransacao_screen.dart
|           widgets/
|                 transacao_form.dart
├───services/
|   └───cache/
|       app_cache_manager.dart
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
Conforme solicitado para o TC4, era necessário implementar uma tecnologia que trouxesse uma camada à mais de segurança para o aplicativo. Desta forma optei por utilizar o <a href="https://pub.dev/packages/crypto/install">Crypto</a>. Seguindo o que temos inclusive nas aulas.

<!--
Colocar aqui exemplo de criptografia que ocorre no App (acho que ficou sem por enquanto.)
-->

Além do Crypto, também implementei de forma mais correta, a autenticação do Firebase. Além disso, coloquei formas de garantir a segurança como: autenticação com Firebase Auth, upload de comprovantes para Firebase Storage, métodos de atualização de senha implementados.

#### Cache  
Para atender as expectativas do TC4, optei pelo uso do Flutter_Cache_Manager.
<a href="https://pub.dev/packages/flutter_cache_manager">Flutter_Cache_Manager</a>

<code>
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';

class TransacaoCacheManager {
  static const key = 'transacoes_cache_key';
  static final DefaultCacheManager _manager = DefaultCacheManager();

  // Salva a lista de transações no cache como JSON
  static Future<void> salvarNoCache(String mesAno, List<TransacaoModel> lista) async {
    final jsonStr = jsonEncode(lista.map((e) => e.toMap()).toList());
    final bytes = utf8.encode(jsonStr);
    await _manager.putFile(
      '${key}_$mesAno', 
      Uint8List.fromList(bytes),
      fileExtension: 'json',
    );
  }

  // Busca do cache
  static Future<List<TransacaoModel>?> buscarDoCache(String mesAno) async {
    final fileInfo = await _manager.getFileFromCache('${key}_$mesAno');
    if (fileInfo != null) {
      final jsonStr = await fileInfo.file.readAsString();
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((e) => TransacaoModel.fromMap(e)).toList();
    }
    return null;
  }
}
</code>

#### Performance e Otimização
Nesta sessão, para atender os requisitos do TC4, inseri funcionalidades que ajudam no loading do aplicativo. Então temos as seguintes implementações:
<ul>
 <li>Lazy initialization para evitar work pesado na construção de widgets (ex.: Future.microtask, addPostFrameCallback).</li>
 <li>Indicações de loading e feedback do usuário (CircularProgressIndicator, diálogos).</li>
 <li>Tratamento assíncrono para operações de rede e I/O.</li>
</ul>

O principal ponto de melhoria neste ponto é o cache, já que trata-se de uma aplicação client, não houveram grandes mudanças significativas em performance. 
Creio que pouca coisa alterou da versão do TC3 para esta.


