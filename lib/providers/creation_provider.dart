// lib/providers/creation_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memecreat/services/file_service.dart';
import 'package:memecreat/services/storage_service.dart';

class CreationProvider extends ChangeNotifier {
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();

  // --- STATE ---
  File? _selectedImage;
  bool _isLoading = false;
  String? _uploadedImageUrl;

  // --- GETTERS ---
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get uploadedImageUrl => _uploadedImageUrl;

  /// Galeriden bir görsel seçer ve state'i günceller.
  Future<void> pickUserImage() async {
    _setLoading(true);
    _selectedImage = await _fileService.pickImageFromGallery();
    _setLoading(false);
  }

  /// Seçilen görseli Firebase Storage'a yükler.
  Future<String?> uploadUserImage() async {
    if (_selectedImage == null) return null;

    final userId = _storageService.currentUserId;
    if (userId == null) {
      print("Hata: Kullanıcı girişi yapılmamış.");
      return null;
    }

    _setLoading(true);
    final path = 'user_faces/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    _uploadedImageUrl = await _storageService.uploadFile(_selectedImage!, path);
    _setLoading(false);

    if (_uploadedImageUrl != null) {
      print('Dosya başarıyla yüklendi: $_uploadedImageUrl');
    }

    return _uploadedImageUrl;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}