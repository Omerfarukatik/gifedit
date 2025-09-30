import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } on PlatformException {
      throw 'invalid-credential';
    } catch (_) {
      throw 'unknown-error';
    }
  }

Future<User?> signIn({required String email, required String password}) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    return Future.error(e.code); // Sadece error code dön
  } catch (e) {
    return Future.error('unknown-error');
  }
}

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
