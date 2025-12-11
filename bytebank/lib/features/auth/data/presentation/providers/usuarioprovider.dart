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