# Bytebank
O projeto está sendo desenvolvido utiizando Flutter.
Esta é a branch oficial para o Tech Challenge Fase 4

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
Uma das principais coisas que eu achava ruim no TC3 é que o formulário de Cadastro/Edição de transação estava mal otimizado, não respeitando o conceito da arquitetura. Desta forma, na tentativa de atingir este objetivo, eu criei o formulário apartado de Transações, desta forma, quando o usuário quiser cadastrar ou editar uma transação o mesmo formulário é exibido, fazendo assim com que fique mais dinâmico e respeitando a arquitetura.

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

Sendo assim, quando a transação é pressionada na listagem, ela abre o formulário para edição. Ajustando assim o saldo, etc.
Um ponto importante aqui é que o componente de SALDO não foi atualizado e está mocado na aplicação por questão de tempo, achei melhor focar na funcionalidade mais relevante que seria a transação.

