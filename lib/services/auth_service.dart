import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> register(String email, String password, String name, String role) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCred.user;

    if (user != null) {
      final appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        role: role,
      );
      await _dbService.saveUser(appUser);
    }

    return user;
  }

  Future<User?> login(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
