// lib/services/download_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart'; // image_gallery_saver yerine bu paketi kullanıyoruz
import 'package:permission_handler/permission_handler.dart'; // Paketleri import ediyoruz
import 'package:memecreat/l10n/app_localizations.dart'; // Yerelleştirme için

class DownloadService {
  // Art arda gelen indirme isteklerini engellemek için bir bayrak.
  bool _isDownloading = false;

  /// Depolama iznini kontrol eden ve gerekirse isteyen fonksiyon.
  /// Android 13+ için `Permission.photos` iznini,
  /// daha eski sürümler için `Permission.storage` iznini yönetir.
  Future<bool> _requestPermission() async {
    // `permission_handler` paketi, Android sürümüne göre doğru izni
    // (storage veya photos) yönetmek için tasarlanmıştır.
    // `Permission.storage` istemek, eski sürümler için depolama,
    // yeni sürümler için ise medya erişim diyaloglarını tetikler.
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // Eğer izin reddedilmişse, tekrar istiyoruz.
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // GIF'i URL'den indirip galeriye kaydeden ana fonksiyon
  Future<void> saveGifToGallery(BuildContext context, String gifUrl) async {
    // Eğer zaten bir indirme işlemi devam ediyorsa, yeni isteği yok say.
    if (_isDownloading) return;

    _isDownloading = true; // İndirme işlemini başlat ve bayrağı ayarla.

    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      // 1. İzinleri kontrol et
      final hasPermission = await _requestPermission();
      // `context`'in hala geçerli olup olmadığını kontrol et.
      if (!context.mounted) return;

      if (!hasPermission) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.permissionRequiredForGallery),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // `context`'in hala geçerli olup olmadığını kontrol et.
      if (!context.mounted) return;

      // 2. GIF verisini indir
      final response = await http.get(Uri.parse(gifUrl));

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        // Dosya adı için URL'den bir parça alalım
        final name = 'memecreat_${DateTime.now().millisecondsSinceEpoch}.gif';

        // 3. Galeriye kaydet
        // `saver_gallery` paketinin yeni versiyonu için parametreler güncellendi.
        final result = await SaverGallery.saveImage(
          bytes,
          fileName: name,
          skipIfExists: false,
        );

        // `context`'in hala geçerli olup olmadığını kontrol et.
        if (!context.mounted) return;

        if (result.isSuccess) {
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(l10n.gifSavedToGallery),
            backgroundColor: Colors.green,
          ));
        } else {
          throw Exception(l10n.failedToSaveGif);
        }
      } else {
        throw Exception('${l10n.failedToDownloadGif} Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Hata: $e');
      // `context`'in hala geçerli olup olmadığını kontrol et.
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e'), backgroundColor: Colors.red));
      }
    } finally {
      // İşlem ne olursa olsun bittiğinde bayrağı sıfırla.
      _isDownloading = false;
    }
  }
}