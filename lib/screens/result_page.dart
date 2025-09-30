// lib/result_page.dart

import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String resultGifUrl;

  const ResultPage({
    super.key,
    required this.resultGifUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşte Eserin!'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tebrikler Kanka!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // İşte o sihirli an! GIF'i gösteriyoruz.
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  resultGifUrl,
                  // Yüklenirken bir animasyon gösterelim
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  },
                  // Hata olursa diye bir ikon gösterelim
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 100,
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Paylaş (Yakında)'),
                onPressed: () {
                  // TODO: Paylaşma fonksiyonunu buraya ekleyeceğiz.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paylaşma özelliği yakında eklenecek!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
