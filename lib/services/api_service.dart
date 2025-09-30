import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _cloudFunctionUrl = 'https://europe-west1-gifedit-24349.cloudfunctions.net/createGif';

  Future<String?> createGif({
    required File userImage,
    File? userGif,
    String? gifTemplateName,
  }) async {
    // --- ADIM 1: GİRDİLERİ LOGLA ---
    print("--- YENİ GIF OLUŞTURMA İSTEĞİ BAŞLADI ---");
    print("Seçilen Yüz Fotoğrafı: ${userImage.path}");
    if (userGif != null) {
      print("Seçilen Kullanıcı GIF'i: ${userGif.path}");
    }
    if (gifTemplateName != null) {
      print("Seçilen Şablon: $gifTemplateName");
    }

    try {
      final formData = FormData();

      // Yüz fotoğrafını ekle
      formData.files.add(MapEntry(
        'face_image',
        await MultipartFile.fromFile(userImage.path, filename: 'face.jpg'),
      ));

      // Kullanıcı GIF'ini ekle
      if (userGif != null) {
        formData.files.add(MapEntry(
          'user_gif',
          await MultipartFile.fromFile(userGif.path, filename: 'user.gif'),
        ));
      }

      // Şablon adını ekle
      if (gifTemplateName != null) {
        formData.fields.add(MapEntry('gif_template', gifTemplateName));
      }

      // --- ADIM 2: GÖNDERİLECEK VERİYİ LOGLA ---
      print("FormData oluşturuldu. Alanlar: ${formData.fields.map((e) => e.key).toList()}, Dosyalar: ${formData.files.map((e) => e.key).toList()}");
      print("Firebase Function'a istek gönderiliyor: $_cloudFunctionUrl");

      final response = await _dio.post(
        _cloudFunctionUrl,
        data: formData,
      );

      // Başarılı yanıtı işle
      if (response.statusCode == 200 && response.data != null) {
        final resultUrl = response.data['result_gif_url'];
        print("İşlem başarılı. Sonuç GIF URL'si: $resultUrl");
        print("--- İSTEK BAŞARIYLA TAMAMLANDI ---");
        return resultUrl;
      } else {
        throw Exception('API\'den beklenen yanıt alınamadı. Status: ${response.statusCode}');
      }

    } on DioException catch (e) {
      // --- ADIM 3: GERÇEK HATAYI YAKALA VE LOGLA ---
      print("--- !!! API İSTEĞİ SIRASINDA HATA (DioException) !!! ---");
      if (e.response != null) {
        // Sunucudan bir yanıt geldiyse, bu en önemli bilgidir.
        print("SUNUCUDAN GELEN YANIT KODU: ${e.response?.statusCode}");
        print("SUNUCUDAN GELEN YANIT VERİSİ (BODY):");
        print(e.response?.data); // <<-- BİZE BU LAZIM!
      } else {
        // Sunucuya hiç ulaşılamadıysa (internet yok, DNS sorunu vb.)
        print("Sunucuya ulaşılamadı. İstek gönderilemedi.");
        print("Dio Hata Mesajı: ${e.message}");
      }
      print("--- HATA DETAYLARI SONU ---");

      // Orijinal hata mesajını koruyalım
      throw Exception('GIF oluşturulurken bir ağ hatası oluştu.');

    } catch (e) {
      print("--- !!! BEKLENMEDİK GENEL HATA (catch) !!! ---");
      print("Hata Tipi: ${e.runtimeType}");
      print("Hata Mesajı: $e");
      print("--- HATA DETAYLARI SONU ---");
      throw Exception('GIF oluşturulamadı.');
    }
  }
}
