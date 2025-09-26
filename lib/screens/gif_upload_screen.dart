// lib/screens/gif_upload_screen.dart (SADECE UI VE YERELLEŞTİRME)

import 'package:flutter/material.dart';

import 'package:memecreat/l10n/app_localizations.dart'; 

import '../../theme/app_theme.dart';
import 'gif_selection_screen.dart'; // Navigasyon hedefi

class GifUploadScreen extends StatelessWidget {
  const GifUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: secondaryTextColor),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selectImageToProcess, // Yerelleştirildi
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 24),

            // Yükleme Butonu (SADECE YER TUTUCU)
            ElevatedButton(
              onPressed: () {
                // TODO: İŞLEVSELLİK - Galeriden fotoğraf seçme (Bir sonraki adımımız)
              },
              child: Text(l10n.selectFromGallery), // Yerelleştirildi
            ),
            const SizedBox(height: 40),

            // Devam Butonu (SADECE NAVİGASYON)
            ElevatedButton(
              onPressed: () {
                // Navigasyon sadece yer tutucu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GifSelectionScreen()),
                );
              },
              child: Text(l10n.continueText), // Yerelleştirildi
            ),
          ],
        ),
      ),
    );
  }
}