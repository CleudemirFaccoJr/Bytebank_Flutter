import 'package:firebase_database/firebase_database.dart';
import 'package:bytebank/features/auth/data/models/usuariomodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importa o novo provider de autenticação
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart'; 

final usuarioProvider = FutureProvider<UsuarioModel?>((ref) async {
  // Observa o estado de autenticação para reagir a mudanças
  final authState = ref.watch(authProvider);

  // Se não estiver autenticado, retorna null (ou lança um erro, se preferir)
  if (!authState.isAuthenticated) {
    return null; 
  }

  final uid = authState.userId; // Garante que o uid está disponível

  final snapshot = await FirebaseDatabase.instance
      .ref("usuarios/$uid")
      .get();

  if (!snapshot.exists || snapshot.value == null) {
      return null;
  }

  // Se o valor existir, retorna o modelo
  return UsuarioModel.fromMap(snapshot.value as Map);
});