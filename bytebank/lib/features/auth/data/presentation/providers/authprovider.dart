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