// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_repository.dart';

  class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<User?> get userStream => _authService.user;

  String _mapAuthErrorToMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'ERROR_INVALID_CREDENTIAL':
      case 'user-not-found':
      case 'invalid-email':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter giriniz.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

Future<bool> signIn({required String email, required String password}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await _authService.signIn(email: email, password: password);
    return true;
  } catch (e) {
    // Firebase kodlarını UI için çevir
    if (e == 'invalid-credential' || e == 'wrong-password' || e == 'user-not-found') {
      _errorMessage = 'E-posta veya şifre hatalı.';
    } else {
      _errorMessage = 'Bir hata oluştu: $e';
    }
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<bool> signUp({required String email, required String password, required String username}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUp(email: email, password: password);
      if (user != null) {
        await _userRepository.createNewUserDocument(user: user, username: username);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _mapAuthErrorToMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
