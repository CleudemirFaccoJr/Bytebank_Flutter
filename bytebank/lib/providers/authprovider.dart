import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userNameFromDatabase = '';

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) async{
      _user = user;
      _userNameFromDatabase = '';
      if (_user != null && _user!.displayName == null) {
        await _fetchUserNameFromDatabase();
      }
      notifyListeners();
    });
  }

  //Função para atualizar senha
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    try{
      final user = _auth.currentUser;
      if(user == null){
        throw Exception('Usuário não autenticado');
      }

      final credenciais = EmailAuthProvider.credential(
        email: user.email!,
        password: senhaAtual,
      ); 

      await user.reauthenticateWithCredential(credenciais);
      await user.updatePassword(novaSenha);
    } on FirebaseAuthException catch(e){
      if(e.code == 'wrong-password'){
        throw Exception('Senha atual incorreta');
      } else {
        throw Exception('Erro ao atualizar senha: ${e.message}');
      }
    } catch(e){
      throw Exception('Erro ao atualizar senha: $e');
    }
  }

  Future<void> _fetchUserNameFromDatabase() async{
    final uid = _user!.uid;
    final dbRef = FirebaseDatabase.instance.ref();

    try {
      final snapshot = await dbRef.child('contas/$uid/nomeUsuario').get();
      if (snapshot.exists) {
        _userNameFromDatabase = snapshot.value as String?;
        await _user!.updateDisplayName(_userNameFromDatabase);
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
      }
    } catch (e) {
      debugPrint('Erro ao buscar nome do usuário: $e');
    }
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String get userName {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    } else if (_userNameFromDatabase != null && _userNameFromDatabase!.isNotEmpty) {
      return _userNameFromDatabase!;
    } else {
      return 'Bytebank';
    }
  }
}