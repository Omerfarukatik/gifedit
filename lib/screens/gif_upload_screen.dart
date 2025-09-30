// lib/screens/gif_upload_screen.dart (SADECE UI VE YERELLEŞTİRME)

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:memecreat/l10n/app_localizations.dart'; 
import 'package:memecreat/providers/creation_provider.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import 'gif_selection_screen.dart'; // Navigasyon hedefi

class GifUploadScreen extends StatelessWidget {
  const GifUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final creationProvider = Provider.of<CreationProvider>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadYourFace), // Başlık
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

            // Görsel Yükleme Alanı (Placeholder)
            AspectRatio(
              aspectRatio: 1.0, // Kare bir alan
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: creationProvider.selectedImage == null
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
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13), // Kenarlıktan biraz daha küçük
                        child: Image.file(
                          creationProvider.selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Yükleme Butonu
            ElevatedButton(
              onPressed: creationProvider.isLoading ? null : () {
                creationProvider.pickUserImage();
              },
              child: creationProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.selectFromGallery),
            ),
            const SizedBox(height: 40),

            // Devam Butonu
            ElevatedButton(
              onPressed: creationProvider.selectedImage == null ? null : () async {
                // Önce görseli yükle
                final imageUrl = await creationProvider.uploadUserImage();

                // Yükleme başarılıysa sonraki ekrana git
                if (imageUrl != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GifSelectionScreen()),
                  );
                } else if (context.mounted) {
                  // Hata durumunda kullanıcıyı bilgilendir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.signUpFailed)), // Yerelleştirilmiş hata mesajı
                  );
                }
              },
              child: Text(l10n.continueText),
            ),
          ],
        ),
      ),
    );
  }
}