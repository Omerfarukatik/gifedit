// lib/services/file_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Cihaz galerisinden dosya seçme işlemlerini yöneten servis.
class FileService {
  final ImagePicker _picker = ImagePicker();

  /// Galeriden bir görsel seçer ve [File] nesnesi olarak döndürür.
  ///
  /// Kullanıcı bir görsel seçmezse `null` döner.
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kaliteyi %80 ile sınırla
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}