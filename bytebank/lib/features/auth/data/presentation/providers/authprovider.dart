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

//Notifier que gerencia o AuthState
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<User?>? _authStateSubscription;

  @override
  AuthState build() {
    //Estado inicial
    state = AuthState(user: FirebaseAuth.instance.currentUser);

    //Configura a escuta do stream no momento da criação do Notifier
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      //Reseta o nome do DB e atualiza o objeto User
      state = state.copyWith(user: user, userNameFromDatabase: '');

      //Se autenticado, verifica se precisa buscar o nome do DB
      if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
        await _fetchUserNameFromDatabase(user);
      }
    });

    //Limpa a assinatura do stream quando o provider é descartado
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return state;
  }

  // --- Métodos de Lógica de Negócio ---

  Future<void> _fetchUserNameFromDatabase(User user) async {
    final uid = user.uid;
    final dbRef = FirebaseDatabase.instance.ref();

    try {
      final snapshot = await dbRef.child('contas/$uid/nomeUsuario').get();
      if (snapshot.exists) {
        final newName = snapshot.value?.toString() ?? '';

        // Tenta atualizar o displayName no Firebase User
        try {
          await user.updateDisplayName(newName);
          await user.reload();

          // Pega a instância User atualizada
          final updatedUser = FirebaseAuth.instance.currentUser;

          // Atualiza o estado com o novo User e o nome do DB
          state = state.copyWith(
            user: updatedUser,
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
        await FirebaseAuth.instance.signOut();
        // O listener do stream cuida da atualização do estado após o signOut
      } catch (e) {
        debugPrint('Erro ao atualizar senha: $e');
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // O listener do stream cuida da atualização do estado após o signOut
    } catch (e) {
      debugPrint('Erro durante o logout: $e');
      // Força a limpeza do estado se o signOut falhar
      state = AuthState(user: null, userNameFromDatabase: '');
      rethrow;
    }
  }
}

// O Provider Global para acesso
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);