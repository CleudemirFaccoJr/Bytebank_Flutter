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

      // 1. Converter anexo para Base64 se existir
      if (arquivoComprovante != null) {
        base64Image = await CryptoUtils.fileToBase64(arquivoComprovante);
      }

      // 2. Gerar Checksum (Criptografia de integridade)
      final tempMap = transacao.toMap();
      tempMap['anexoUrl'] = base64Image;
      final checksum = CryptoUtils.gerarChecksum(tempMap);

      // 3. Preparar modelo final
      final transacaoFinal = transacao.copyWith(
        anexoUrl: base64Image,
        checksum: checksum,
      );

      // 4. Salvar APENAS no Realtime Database
      final dbRef = FirebaseDatabase.instance.ref();
      final mesAno = transacaoFinal.data.substring(3); // Ex: 12-2023
      
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