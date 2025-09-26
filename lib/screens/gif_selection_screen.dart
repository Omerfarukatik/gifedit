// lib/screens/gif_selection_screen.dart (Güncellenmiş Tam Kod)
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import '../../theme/app_theme.dart'; 
// ... Diğer gerekli importlar (CreationProvider, FileService, vb.)

class GifSelectionScreen extends StatelessWidget {
  const GifSelectionScreen({super.key});

  // Örnek GIF verileri
  final List<String> defaultGifs = const [
    'Dans', 'Kızgın', 'Şaşkın', 'Koşma', 'Göz Kırpma', 'Sürpriz',"faruk bey","gülme","alkış","mutlu","üzgün","şaka","yemek","uyku","çalışma"
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectAGifTemplate), // YERELLEŞTİRİLDİ
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Başlık: Varsayılan GIF'ler
            Text(
              l10n.defaultGifs, // YERELLEŞTİRİLDİ
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor, // Temaya duyarlı
              ),
            ),
            const SizedBox(height: 10),
            
            // GIF IZGARASI (EKRANIN BÜYÜK KISMINI KAPLAR)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0, // Kare kartlar
                ),
                itemCount: defaultGifs.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      // Arkaplan rengi temadan, kenarlık mor
                      color: theme.cardColor, 
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      defaultGifs[index], // Bu da yerelleştirilebilir
                      style: TextStyle(color: primaryTextColor, fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Kendi GIF'ini Yükleme Butonu
            ElevatedButton(
              onPressed: () {
                // TODO: İŞLEVSELLİK - Kullanıcının kendi GIF'ini seçme
              },
              style: ElevatedButton.styleFrom(
                // Sabitlenmiş arka plan rengi kaldırıldı, tema devralacak
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(l10n.uploadYourOwnGif), // YERELLEŞTİRİLDİ
            ),
            
            const SizedBox(height: 15),
            
            // Oluşturma Butonu
            ElevatedButton(
              onPressed: () {
                // TODO: İŞLEVSELLİK - API Çağrısı
              },
              child: Text(l10n.createGif), // YERELLEŞTİRİLDİ
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}