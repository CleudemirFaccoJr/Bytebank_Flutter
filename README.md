# Bytebank
O projeto está sendo desenvolvido utiizando Flutter.
Esta é a branch oficial para o Tech Challenge Fase 4

<br/>Desenvolvido por: Cleudemir Facco Junior
<br/><br/>![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)
<br/>

Esta versão aplicou refatorações e melhorias importantes na organização do código, gerenciamento de estado, responsividade e segurança de forma incremental. A base já está modularizada visualmente e integrada ao Firebase; várias práticas sugeridas (lazy loading, feedback de carregamento, uso de streams) foram adotadas. Ainda há espaço para evolução para uma Clean Architecture completa, cache encriptado e state management reativo mais avançado.

### Executando a aplicação
Desta vez, vamos rodar a aplicação direto de uma branch específica para o TC fase 4:

<b>Passo a passo</b>
1- Abra o terminal na raiz do projeto:

```
cd path/para/Bytebank_Flutter
```

2- Troque para a branch correta:

```
git fetch origin
git checkout techchallenge_fase4
git pull origin techchallenge_fase4
```

3- Instale as dependências:

```
flutter pub get
```

4- <i>(Opcional)</i> Limpe build antigo:

```
flutter clean
flutter pub get
```

5- Execute a aplicação:
  5.1 - Liste dispositivos:
  
  ```
  flutter devices
  ```

  5.2- Rode na plataforma desejada (ex.: Android):
  ```
  flutter run -d <deviceId>
  ```

#### State Management Patterns
Para o Tech Challenge fase 4, foi solicitado que houvesse a implementação de SMP avançados. Como o meu projeto está todo focado em flutter, eu analisei e optei por utilizar o Riverpod para fazer isso.

<a href="https://pub.dev/packages/riverpod/install">Riverpod</a>

Pelo que pesquisei, trata-se de um conceito mais minimalista e simplificado. Por conta de tempo e escopo do projeto optei por esta tecnologia.

Então, um exemplo do uso do Riverpod para a nova necessidade do Tech Challenge é o authprovider.dart:

 ```flutter

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final User? user;
  final String userNameFromDatabase;

  AuthState({
    required this.user,
    this.userNameFromDatabase = '',
  });

  bool get isAuthenticated => user != null;

  String get displayName {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    } else if (userNameFromDatabase.isNotEmpty) {
      return userNameFromDatabase;
    } else {
      return 'Bytebank';
    }
  }

  String get userId => user?.uid ?? '';

  AuthState copyWith({
    User? user,
    String? userNameFromDatabase,
  }) {
    return AuthState(
      user: user ?? this.user,
      userNameFromDatabase: userNameFromDatabase ?? this.userNameFromDatabase,
    );
  }
}

// Este provider observa diretamente o Firebase e garante que o estado esteja sempre sincronizado
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

//Notifier Principal
class AuthNotifier extends Notifier<AuthState> {
  
  @override
  AuthState build() {
    final authResult = ref.watch(firebaseAuthStateProvider);

    return authResult.maybeWhen(
      data: (user) {
        if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
          Future.microtask(() => _fetchUserNameFromDatabase(user));
        }
        return AuthState(user: user);
      },
      // Estado padrão enquanto carrega ou se der erro
      orElse: () => AuthState(user: FirebaseAuth.instance.currentUser),
    );
  }


  Future<void> _fetchUserNameFromDatabase(User user) async {
    final uid = user.uid;
    final dbRef = FirebaseDatabase.instance.ref();

    try {
      final snapshot = await dbRef.child('contas/$uid/nomeUsuario').get();
      if (snapshot.exists) {
        final newName = snapshot.value?.toString() ?? '';

        try {
          await user.updateDisplayName(newName);
          await user.reload();

          state = state.copyWith(
            user: FirebaseAuth.instance.currentUser,
            userNameFromDatabase: newName,
          );
        } catch (e) {
          debugPrint('Erro ao atualizar displayName: $e');
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar nome do usuário: $e');
    }
  }

  Future<void> atualizarSenha(String novaSenha) async {
    if (state.user != null) {
      try {
        await state.user!.updatePassword(novaSenha);
        await logout();
      } catch (e) {
        debugPrint('Erro ao atualizar senha: $e');
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Erro durante o logout: $e');
      state = AuthState(user: null, userNameFromDatabase: '');
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

 ```

 Para exemplificar melhor o que está acontecendo então, o AuthProvider fica responsável por dizer pra aplicação qual e se há um usuário logado. Aqui no cadastrar_transacao_notifier.dart temos o funcionamento deste Provider com riverpod:

 ```flutter

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';
import 'package:bytebank/shared/utils/cypto_utils.dart';

class CadastrarTransacaoNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> cadastrar({
    required TransacaoModel transacao,
    File? arquivoComprovante,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = ref.read(authProvider).userId;
      String base64Image = "";

      //Converter anexo para Base64 se existir
      if (arquivoComprovante != null) {
        base64Image = await CryptoUtils.fileToBase64(arquivoComprovante);
      }

      //Gerar Checksum (Criptografia de integridade)
      final tempMap = transacao.toMap();
      tempMap['anexoUrl'] = base64Image;
      final checksum = CryptoUtils.gerarChecksum(tempMap);

      //Preparar modelo final
      final transacaoFinal = transacao.copyWith(
        anexoUrl: base64Image,
        checksum: checksum,
      );

      //Salvar APENAS no Realtime Database
      final dbRef = FirebaseDatabase.instance.ref();
      final mesAno = transacaoFinal.data.substring(3);
      
      await dbRef
          .child("transacoes")
          .child(mesAno)
          .child(userId)
          .child(transacaoFinal.idTransacao)
          .set(transacaoFinal.toMap());

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final cadastrarTransacaoProvider =
    AsyncNotifierProvider<CadastrarTransacaoNotifier, void>(CadastrarTransacaoNotifier.new);

```



Toda aplicação agora roda com Riverpod. De modo que todo o gerenciamento de estados passa por ele. Claro, por conta do escopo da aplicação, não notei grandes diferenças entre o Riverpod e o uso de Providers... Mas, na tentiva de atender às expectativas do Tech Challenge, eu implementei a funcionalidade.

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

Seguindo então os padrões de Clean Architecture, eu estruturei os models para cada tipo de Entidade da aplicação. Creio que existe espaço para melhorias no que se refere ao padrão de arquitetura. 
Então temos de fato as seguintes entidades:

```
Usuario
Transacao
Saldo

```

Desta forma, os conceitos estão sendo seguidos, e as Entidades podem ser reutilizadas em diversas áreas do aplicativo.

#### Segurança
Conforme solicitado para o TC4, era necessário implementar uma tecnologia que trouxesse uma camada à mais de segurança para o aplicativo. Implementei de forma mais correta, a autenticação do Firebase. Além disso, coloquei formas de garantir a segurança como: autenticação com Firebase Auth, upload de comprovantes para Firebase Storage, métodos de atualização de senha implementados.

Para além disso, utilizando o <a href="https://pub.dev/packages/crypto" target="_blank">Crypto</a>, eu inseri técnicas de criptografia e integridade nas transações. Foquei mais uma vez nesta funcionalidade, visto que para login por exemplo, eu já uso o Authentication do próprio Firebase e dados sensíveis do usuário (como a senha), não é salva no Realtime Database.

 ```flutter

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';
import 'package:bytebank/shared/utils/cypto_utils.dart';

class CadastrarTransacaoNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> cadastrar({
    required TransacaoModel transacao,
    File? arquivoComprovante,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = ref.read(authProvider).userId;
      String base64Image = "";

      //Converter anexo para Base64 se existir
      if (arquivoComprovante != null) {
        base64Image = await CryptoUtils.fileToBase64(arquivoComprovante);
      }

      //Gerar Checksum (Criptografia de integridade)
      final tempMap = transacao.toMap();
      tempMap['anexoUrl'] = base64Image;
      final checksum = CryptoUtils.gerarChecksum(tempMap);

      //Preparar modelo final
      final transacaoFinal = transacao.copyWith(
        anexoUrl: base64Image,
        checksum: checksum,
      );

      //Salvar APENAS no Realtime Database
      final dbRef = FirebaseDatabase.instance.ref();
      final mesAno = transacaoFinal.data.substring(3);
      
      await dbRef
          .child("transacoes")
          .child(mesAno)
          .child(userId)
          .child(transacaoFinal.idTransacao)
          .set(transacaoFinal.toMap());

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final cadastrarTransacaoProvider =
    AsyncNotifierProvider<CadastrarTransacaoNotifier, void>(CadastrarTransacaoNotifier.new);

 ```

 Aqui então no trecho:

  ```flutter

 //Gerar Checksum (Criptografia de integridade)
      final tempMap = transacao.toMap();
      tempMap['anexoUrl'] = base64Image;
      final checksum = CryptoUtils.gerarChecksum(tempMap);

```

O módulo Crypto atua como um guardião da integridade da transação, garantindo que os dados persistidos no banco não sejam adulterados — seja de forma acidental ou maliciosa — após o momento do cadastro.

Sua função não é apenas “criptografar”, mas assegurar confiança e rastreabilidade dos dados.

No fluxo de cadastro de uma transação, o Crypto entra em dois momentos críticos:

<ol>
  <li>Tratamento seguro do anexo (comprovante da transação)<br/>
    Quando a transação possui um comprovante (arquivo):
    <ul>
      <li>O arquivo não é armazenado diretamente como binário ou path externo</li>
      <li>Ele é convertido para Base64, garantindo compatibilidade total com o Firebase Realtime Database</li>
      <li>Persistência autocontida da transação</li>
      <li>Redução de dependências externas (ex: storage separado)</li>
    </ul>
  </li>
  <li>Geração de checksum (integridade criptográfica)<br/>
  Antes da gravação no banco, o sistema gera um checksum criptográfico, que funciona como uma assinatura digital da transação. Na prática funciona da seguinte forma:
  <ol>
    <li>A transação é convertida para Map</li>
    <li>O anexo (em Base64) é incluído no conteúdo</li>
    <li>Todo esse conjunto de dados é processado pelo Crypto</li>
    <li>O resultado é um hash único, sensível a qualquer alteração</li>
  </ol>
  </li>
</ol>

Isso significa que qualquer alteração posterior gerará um checksum incompatível permitindo assim detectar uma violação de integridade. Claro, é uma aplicação BEM simplória para a aplicação e em um cenário real, seria claramente insuficiente pra impedir fraudes por exemplo.

Mas por que isso é importante?
Esta abordagem demonstra benefícios como:

<ul>
  <li>Integridade dos dados: Garante que a transação armazenada é exatamente a mesma que foi cadastrada.</li>
  <li>Segurança lógica: Mesmo que alguém tenha acesso ao banco, alterações manuais podem ser detectadas.</li>
  <li>Auditoria e validação futura: O checksum permite:
   <ul>
     <li>Conferência de consistência</li>
     <li>Comparação entre dados carregados e dados originais</li>
     <li>Base sólida para futuras rotinas de validação ou auditoria</li>
   </ul>
  </li>
  <li>Arquitetura consciente: A criptografia não depende do banco, mas do domínio da aplicação — o que é uma excelente prática de engenharia de software.</li>
</ul>

O módulo Crypto assegura que cada transação registrada seja não apenas armazenada, mas criptograficamente validada, preservando sua integridade desde o momento do cadastro até qualquer verificação futura. 

#### Cache  
Para atender as expectativas do TC4, optei pelo uso do Flutter_Cache_Manager.
<a href="https://pub.dev/packages/flutter_cache_manager">Flutter_Cache_Manager</a>

 ```flutter
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
 ```

#### Performance e Otimização
Nesta sessão, para atender os requisitos do TC4, inseri funcionalidades que ajudam no loading do aplicativo. Então temos as seguintes implementações:
<ul>
 <li>Lazy initialization para evitar work pesado na construção de widgets (ex.: <a href="#microtask">Future.microtask</a>, addPostFrameCallback).</li>
 <li>Indicações de loading e feedback do usuário (CircularProgressIndicator, diálogos).</li>
 <li>Tratamento assíncrono para operações de rede e I/O.</li>
</ul>
<div id="microtask">

 ```flutter
  class AuthNotifier extends Notifier<AuthState> {
  
  @override
  AuthState build() {
    final authResult = ref.watch(firebaseAuthStateProvider);

    return authResult.maybeWhen(
      data: (user) {
        if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
          Future.microtask(() => _fetchUserNameFromDatabase(user));
        }
        return AuthState(user: user);
      },
      // Estado padrão enquanto carrega ou se der erro
      orElse: () => AuthState(user: FirebaseAuth.instance.currentUser),
    );
  }
  }
  ```
</div>

O principal ponto de melhoria neste ponto é o cache, já que trata-se de uma aplicação client, não houveram grandes mudanças significativas em performance. 
Creio que pouca coisa alterou da versão do TC3 para esta.

#### Modularização
Um dos principais pontos de atenção identificados no TC3 foi a forma como o formulário de Cadastro e Edição de Transações estava acoplado à camada de Transações como um todo, violando princípios importantes de organização, reutilização e responsabilidade única dentro da arquitetura.

Esse acoplamento resultava em:
 <ul>
   <li>Código duplicado</li>
   <li>Dificuldade de manutenção</li>
   <li>Baixa reutilização do formulário</li>
   <li>Forte dependência do contexto de tela</li>
 </ul>

O principal objetivo da modularização foi desacoplar o formulário da lógica de cadastro/edição, transformando-o em um componente reutilizável, previsível e alinhado à arquitetura da aplicação.
Para isso, o formulário passou a existir como um módulo independente, responsável exclusivamente pela captura e validação dos dados da transação, sem qualquer conhecimento sobre:
  <ul>
    <li>Onde os dados serão persistidos</li>
    <li>Se a transação está sendo criada ou editada</li>
    <li>Qual regra de negócio será aplicada após o submit</li>
  </ul>

 ```flutter

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bytebank/app_colors.dart';

//Importando o model de Transacao
import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';

class TransacaoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController valorController;
  final TextEditingController descController;
  final Function(TipoTransacao) onTipoChanged;
  final Function(CategoriaTransacao) onCategoriaChanged;
  final Function(File?) onImagePicked;
  final TipoTransacao tipoInicial;
  final CategoriaTransacao categoriaInicial;

  const TransacaoForm({
    super.key,
    required this.formKey,
    required this.valorController,
    required this.descController,
    required this.onTipoChanged,
    required this.onCategoriaChanged,
    required this.onImagePicked,
    this.tipoInicial = TipoTransacao.deposito,
    this.categoriaInicial = CategoriaTransacao.outros,
  });

  @override
  State<TransacaoForm> createState() => _TransacaoFormState();
}

class _TransacaoFormState extends State<TransacaoForm> {
  late TipoTransacao _tipo;
  late CategoriaTransacao _categoria;
  File? _image;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
    _categoria = widget.categoriaInicial;
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.corBytebank),
      prefixIcon: Icon(icon, color: AppColors.cinzaCardTexto),
      prefixText: prefixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.verdeClaroHover),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.verdeClaroHover),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: AppColors.verdeClaroHover,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      widget.onImagePicked(_image);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Câmera"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeria"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // --- Dropdown Tipo Transação ---
          DropdownButtonFormField<TipoTransacao>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo de Transação'),
            style: TextStyle(
              color: AppColors.cinzaCardTexto,
            ),
            items: TipoTransacao.values.map((t) => DropdownMenuItem(
              value: t, 
              child: Text(t.label)
            )).toList(),
            onChanged: (v) { 
              if (v != null) {
                setState(() => _tipo = v); 
                widget.onTipoChanged(v); 
              }
            },
          ),

          const SizedBox(height: 16),

          // --- Dropdown Categoria ---
          DropdownButtonFormField<CategoriaTransacao>(
            initialValue: _categoria,
            decoration: const InputDecoration(labelText: 'Categoria'),
            style: TextStyle(
              color: AppColors.cinzaCardTexto,
            ),
            items: CategoriaTransacao.values.map((c) => DropdownMenuItem(
              value: c, 
              child: Text(c.label)
            )).toList(),
            onChanged: (v) { 
              if (v != null) {
                setState(() => _categoria = v); 
                widget.onCategoriaChanged(v); 
              }
            },
          ),
          
          const SizedBox(height: 16),

          // Campo Valor
          TextFormField(
            controller: widget.valorController,
            style: const TextStyle(color: AppColors.cinzaCardTexto),
            decoration: _inputDecoration("Valor", Icons.monetization_on, prefixText: 'R\$ '),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Informe o valor' : null,
          ),

          const SizedBox(height: 16),

          // Campo Descrição
          TextFormField(
            controller: widget.descController,
            style: const TextStyle(color: AppColors.cinzaCardTexto),
             decoration: _inputDecoration("Descrição", Icons.description),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe uma descrição' : null,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, 
            child: OutlinedButton.icon(
              onPressed: _showImageOptions,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.corBytebank),
              ),
              icon: Icon(
                _image == null ? Icons.add_a_photo : Icons.check_circle, 
                color: AppColors.corBytebank
              ),
              label: Text(
                _image == null ? 'Selecionar Comprovante' : 'Comprovante Selecionado',
                style: const TextStyle(color: AppColors.corBytebank),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  ```

O componente TransacaoForm foi projetado para ser agnóstico ao fluxo em que está inserido. Ele recebe tudo o que precisa via injeção de dependências, através de parâmetros:
<b>Estado e controle<b>
 <ul>
   <li>GlobalKey<FormState></li>
   <li>TextEditingController para valor e descrição</li>
 </ul>

Isso permite que a tela pai controle completamente o ciclo de vida dos dados, seja no cadastro ou na edição.

<b>Comportamentos externos (Callbacks)/b>
O formulário não decide nada sozinho. Toda alteração relevante é comunicada para fora via callbacks:
<ul>
  <li>onTipoChanged</li>
  <li>onCategoriaChanged</li>
  <li>onImagePicked</li>
</ul>

Dessa forma:

 <ul>
   <li>O formulário emite eventos</li>
   <li>A camada superior decide o que fazer com eles</li>
 </ul>

Esse padrão mantém o componente de modo geral como: previsível, reutilizável e fácil de testar.

<b>Sobre o saldo:</b>
O componente responsável pelo saldo não foi integrado ao fluxo de atualização neste momento, permanecendo mocado na aplicação.
Essa decisão foi tomada de forma consciente, priorizando:
<ul>
  <li>A entrega da funcionalidade mais relevante (transações)</li>
  <li>A validação do fluxo completo de cadastro e edição</li>
  <li>A estabilidade da arquitetura proposta</li>
</ul>

O desacoplamento promovido pela modularização garante que a integração futura do saldo possa ser realizada sem impacto estrutural no formulário.

A modularização do TransacaoForm transforma um formulário antes rígido e acoplado em um componente reutilizável, flexível e alinhado à arquitetura da aplicação.
Essa abordagem não apenas melhora a manutenibilidade do código, como também cria uma base sólida para futuras evoluções do sistema, sem retrabalho ou duplicação de responsabilidades.
