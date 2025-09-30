// lib/services/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> createNewUserDocument({required User user, required String username}) async {
    final now = DateTime.now().toUtc();
    final initialLocaleCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    final userData = {
      'avatarUrl': '',
      'email': user.email,
      'username': username,
      'isPremium': false,
      'joinDate': now,
      'totalLikes': 0,
      'stats': {'creationsCount': 0, 'totalLikes': 0},
      'settings': {'theme': 'system', 'locale': initialLocaleCode}
    };

    await _firestore.collection(_collection).doc(user.uid).set(userData);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    return doc.data();
  }
}