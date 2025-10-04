// lib/services/download_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart'; // image_gallery_saver yerine bu paketi kullanıyoruz
import 'package:permission_handler/permission_handler.dart'; // Paketleri import ediyoruz
import 'package:memecreat/l10n/app_localizations.dart'; // Yerelleştirme için

class DownloadService {
  // Art arda gelen indirme isteklerini engellemek için bir bayrak.
  bool _isDownloading = false;

  // GIF'i URL'den indirip galeriye kaydeden ana fonksiyon
  Future<void> saveGifToGallery(BuildContext context, String gifUrl) async {
    debugPrint("--- İNDİRME BAŞLADI: saveGifToGallery fonksiyonu çağrıldı. ---");

    // Eğer zaten bir indirme işlemi devam ediyorsa, yeni isteği yok say.
    if (_isDownloading) return;

    _isDownloading = true; // İndirme işlemini başlat ve bayrağı ayarla.

    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      // --- YENİ İZİN İSTEME MANTIĞI ---
      debugPrint("1. Adım: Depolama izni durumu kontrol ediliyor...");
      var status = await Permission.photos.status; // 'storage' yerine 'photos' kullanıyoruz.
      debugPrint("==> Mevcut İzin Durumu: $status");

      // 1. İzin durumu 'denied' ise (henüz sorulmamış veya bir kez reddedilmiş), tekrar sor.
      if (status.isDenied) {
        debugPrint("İzin 'denied' olduğu için kullanıcıdan izin isteniyor...");
        status = await Permission.photos.request(); // 'storage' yerine 'photos' kullanıyoruz.
        debugPrint("==> Yeni İzin Durumu: $status");
      }

      // 2. İzin durumu kalıcı olarak reddedilmişse, kullanıcıyı ayarlara yönlendir.
      if (status.isPermanentlyDenied) {
        debugPrint("HATA: İzin kalıcı olarak reddedilmiş. Ayarlara yönlendirme mesajı gösteriliyor.");
        if (!context.mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.permissionPermanentlyDenied),
            backgroundColor: Colors.orange,
            action: SnackBarAction(label: l10n.settings, onPressed: openAppSettings),
          ),
        );
        _isDownloading = false; // Bayrağı sıfırla ve çık
        return;
      }

      // 3. İzin hala verilmemişse (kullanıcı diyalogda reddettiyse), mesaj göster ve çık.
      if (!status.isGranted) {
        debugPrint("HATA: İzin verilmedi. 'İzin gerekli' mesajı gösteriliyor.");
        if (!context.mounted) return;
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(l10n.permissionRequiredForGallery),
          backgroundColor: Colors.orange,
        ));
        _isDownloading = false; // Bayrağı sıfırla ve çık
        return;
      }

      debugPrint("2. Adım: İzinler tamam. GIF indiriliyor: $gifUrl");
      // 2. GIF verisini indir
      final response = await http.get(Uri.parse(gifUrl));

      debugPrint("==> HTTP Yanıt Kodu: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        // Dosya adı için URL'den bir parça alalım
        final name = 'memecreat_${DateTime.now().millisecondsSinceEpoch}.gif';

        debugPrint("3. Adım: GIF başarıyla indirildi. Galeriye kaydediliyor...");
        // 3. Galeriye kaydet
        // `saver_gallery` paketinin yeni versiyonu için parametreler güncellendi.
        final result = await SaverGallery.saveImage(
          bytes,
          fileName: name,
          skipIfExists: false,
        );

        // `context`'in hala geçerli olup olmadığını kontrol et.
        if (!context.mounted) return;

        debugPrint("==> Galeriye Kaydetme Sonucu: ${result.isSuccess}");
        if (result.isSuccess) {
          debugPrint("BAŞARILI: GIF galeriye kaydedildi!");
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(l10n.gifSavedToGallery),
            backgroundColor: Colors.green,
          ));
        } else {
          debugPrint("HATA: saver_gallery paketi GIF'i kaydedemedi.");
          throw Exception(l10n.failedToSaveGif);
        }
      } else {
        debugPrint("HATA: GIF indirilemedi. Sunucu hatası.");
        throw Exception('${l10n.failedToDownloadGif} Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('!!! CATCH BLOĞU: Beklenmedik bir hata oluştu: $e');
      // `context`'in hala geçerli olup olmadığını kontrol et.
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e'), backgroundColor: Colors.red));
      }
    } finally {
      // İşlem ne olursa olsun bittiğinde bayrağı sıfırla.
      _isDownloading = false;
      debugPrint("--- İNDİRME BİTTİ: 'finally' bloğu çalıştı, kilit kaldırıldı. ---");
    }
  }
}