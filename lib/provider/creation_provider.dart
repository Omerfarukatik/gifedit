// lib/providers/creation_provider.dart
import 'package:flutter/material.dart';
import 'dart:io';

class CreationProvider with ChangeNotifier {
  // İşlenecek yüz görselini tutar
  File? _userFaceImage;
  
  // İşlenecek GIF şablonunu tutar (Gelecek adımlar için)
  File? _customGifFile;
  
  // Getter'lar
  File? get userFaceImage => _userFaceImage;
  File? get customGifFile => _customGifFile;

  // Setter: Yüz görselini ayarlar
  void setUserFaceImage(File? image) {
    _userFaceImage = image;
    notifyListeners();
  }

  // Setter: Özel GIF dosyasını ayarlar
  void setCustomGifFile(File? gif) {
    _customGifFile = gif;
    notifyListeners();
  }

  // Formu temizler (İşlem bitince)
  void clearCreationData() {
    _userFaceImage = null;
    _customGifFile = null;
    notifyListeners();
  }
}