// lib/screens/result_page.dart (YENİ, GÜZELLEŞTİRİLMİŞ ZAFER SAHNESİ)

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart'; // FadeInImage için gerekli. pubspec.yaml'a ekle!

class ResultPage extends StatelessWidget {
  final String resultGifUrl; // Parametre adını 'gifUrl' olarak standartlaştıralım.

  const ResultPage({
    super.key,
    required this.resultGifUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Önceki sayfaya ve en başa (ana sayfaya) gitmek için Navigator'ı alalım.
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşte Eserin!'),
        automaticallyImplyLeading: false, // Geri tuşunu kaldırıyoruz, kontrol bizde.
      ),
      body: Center(
        child: SingleChildScrollView( // Farklı ekran boyutlarında taşmayı önler.
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tebrikler Kanka!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Eserin şimdi tüm dünyayla paylaşılmaya hazır.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // === ZAFER ANI: PARLAYAN GIF ===
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      blurRadius: 20.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  // ESKİ Image.network YERİNE FadeInImage.
                  // `precacheImage` sayesinde placeholder hiç görünmeyecek, direkt resim gelecek.
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage, // Şeffaf bir placeholder
                    image: resultGifUrl,
                    fit: BoxFit.contain,
                    // Hata olursa diye bir ikon gösterelim
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.red,
                          size: 100,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // === EYLEM BUTONLARI ===



              const SizedBox(height: 15),

              Row(
                children: [
                  // 2. YENİ BİR TANE DAHA YAP
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Mevcut ResultPage'i kapatıp bir önceki sayfaya (GifSelection) döner.
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 45),
                      ),
                      child: const Text('Yeni Yap'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 3. ANA SAYFAYA DÖN
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Mevcut ekran dahil, ana sayfaya kadar olan tüm ekranları kapatır.
                        navigator.popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 45),
                      ),
                      child: const Text('Ana Sayfa'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

