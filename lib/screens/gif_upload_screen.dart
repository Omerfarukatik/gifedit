// lib/screens/gif_upload_screen.dart (TAM VE GÜNCEL HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';

// Servislerimizi ve diğer ekranları import ediyoruz
import '../../services/image_picker_service.dart';
import 'gif_selection_screen.dart';
import '../../theme/app_theme.dart';

class GifUploadScreen extends StatefulWidget {
  const GifUploadScreen({super.key});

  @override
  State<GifUploadScreen> createState() => _GifUploadScreenState();
}

class _GifUploadScreenState extends State<GifUploadScreen> {
  File? _selectedImage;
  final ImagePickerService _pickerService = ImagePickerService();

  // Galeriden yüz fotoğrafı seçme fonksiyonu
  Future<void> _pickImage() async {
    // Servisimizdeki doğru fonksiyonu çağırıyoruz
    final File? image = await _pickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Sonraki ekrana gitme ve kontrol fonksiyonu
  void _navigateToNextScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedImage != null) {
      // Resim seçildiyse, bir sonraki ekrana git ve resmi parametre olarak gönder.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GifSelectionScreen(userImage: _selectedImage!),
        ),
      );
    } else {
      // Resim seçilmediyse, kullanıcıyı uyar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectAnImageFirst),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadYourFace),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.uploadYourFace,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 16),

            // Resim gösterme alanı
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary, width: 2),
                image: _selectedImage != null
                    ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 50, color: secondaryTextColor),
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectImageToProcess,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              )
                  : null,
            ),
            const SizedBox(height: 24),

            // "Galeriden Seç" Butonu
            ElevatedButton(
              onPressed: _pickImage, // Doğru fonksiyonu çağırıyor
              child: Text(l10n.selectFromGallery),
            ),
            const SizedBox(height: 40),

            // "Devam Et" Butonu
            ElevatedButton(
              onPressed: () => _navigateToNextScreen(context), // context ile çağırıyor
              child: Text(l10n.continueText),
            ),
          ],
        ),
      ),
    );
  }
}
