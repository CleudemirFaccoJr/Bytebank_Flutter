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