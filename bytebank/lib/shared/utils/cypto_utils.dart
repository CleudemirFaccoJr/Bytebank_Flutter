import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  // Converte arquivo para String Base64
  static Future<String> fileToBase64(File file) async {
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  // Gera hash de integridade (Criptografia SHA-256)
  static String gerarChecksum(Map<String, dynamic> data) {
    // Convertemos o mapa em string para gerar o hash
    final content = jsonEncode(data);
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}