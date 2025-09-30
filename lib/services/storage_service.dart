// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage ile dosya yükleme işlemlerini yöneten servis.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verilen [file] dosyasını Firebase Storage'a yükler.
  ///
  /// [path] parametresi, dosyanın yükleneceği yolu belirtir.
  /// Örneğin: 'user_faces/userId/image.jpg'
  /// Yükleme başarılı olursa dosyanın indirme URL'sini [String] olarak döndürür.
  /// Hata durumunda `null` döner.
  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      return null;
    }
  }

  /// Mevcut kullanıcının kimliğini (UID) alır.
  String? get currentUserId => _auth.currentUser?.uid;
}