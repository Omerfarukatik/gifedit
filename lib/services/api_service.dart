import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final Dio _dio = Dio();
  // Cloud Function URL'n aynı, dokunmadım.
  final String _cloudFunctionUrl = 'https://europe-west1-gifedit-24349.cloudfunctions.net/createGif';

  // =======================================================================
  // =       İŞTE SENİN FONKSİYONUNUN, REMIX'İ DE DESTEKLEYEN HALİ       =
  // =======================================================================
  Future<String?> createGif({
    required File userImage, // Yüz resmi her zaman gerekli
    // 3 senaryodan sadece biri dolu olacak:
    File? userGif,
    String? gifTemplateName,
    String? gifTemplateUrl, // <<<<<<<<<<<<<<<< YENİ REMIX PARAMETRESİ
  }) async {
    // --- ADIM 1: GİRDİLERİ LOGLA ---
    print("--- YENİ GIF OLUŞTURMA İSTEĞİ BAŞLADI ---");
    print("Seçilen Yüz Fotoğrafı: ${userImage.path}");
    if (userGif != null) print("Seçilen Kullanıcı GIF'i: ${userGif.path}");
    if (gifTemplateName != null) print("Seçilen Şablon ID'si: $gifTemplateName");
    if (gifTemplateUrl != null) print("Seçilen Şablon URL'si (Remix): $gifTemplateUrl"); // Yeni log

    // Girdi kontrolü
    if (userGif == null && gifTemplateName == null && gifTemplateUrl == null) {
      throw ArgumentError("Bir GIF kaynağı (dosya, template adı veya template URL'si) belirtilmelidir.");
    }

    try {
      final formData = FormData();

      // --- Ortak Alanları Ekle ---
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış!');
      formData.fields.add(MapEntry('userId', userId));

      // Yüz fotoğrafını ekle
      formData.files.add(MapEntry(
        'face_image',
        await MultipartFile.fromFile(userImage.path, filename: 'face.jpg'),
      ));

      // --- AKILLI BLOK: GIF KAYNAĞINI EKLE ---
      if (userGif != null) {
        // Senaryo 1: Kullanıcı kendi GIF'ini yükledi
        formData.files.add(MapEntry(
          'user_gif',
          await MultipartFile.fromFile(userGif.path, filename: 'user.gif'),
        ));
      } else if (gifTemplateName != null) {
        // Senaryo 2: Kullanıcı bir şablon ID'si seçti
        formData.fields.add(MapEntry('gif_template', gifTemplateName));
      } else if (gifTemplateUrl != null) {
        // Senaryo 3: Remix!
        formData.fields.add(MapEntry('gif_template_url', gifTemplateUrl));
      }

      // --- ADIM 2: GÖNDERİLECEK VERİYİ LOGLA ---
      print("FormData oluşturuldu. Alanlar: ${formData.fields.map((e) => '${e.key}: ${e.value}').toList()}, Dosyalar: ${formData.files.map((e) => e.key).toList()}");
      print("Firebase Function'a istek gönderiliyor...");

      // --- İsteği Gönder ---
      final response = await _dio.post(
        _cloudFunctionUrl,
        data: formData,
      );

      // --- Yanıtı İşle ---
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final resultUrl = response.data['result_gif_url'];
        print("İşlem başarılı. Sonuç GIF URL'si: $resultUrl");
        print("--- İSTEK BAŞARIYLA TAMAMLANDI ---");
        return resultUrl;
      } else {
        // Backend'den `success: false` geldiyse, hatayı alıp fırlat
        final errorMessage = response.data?['error'] ?? 'API\'den beklenen yanıt alınamadı.';
        throw Exception('API Hatası: ${response.statusCode} - $errorMessage');
      }

    } on DioException catch (e) {
      // Senin mükemmel hata loglama yapın aynı kaldı, dokunmadım.
      print("--- !!! API İSTEĞİ SIRASINDA HATA (DioException) !!! ---");
      if (e.response != null) {
        print("SUNUCUDAN GELEN YANIT KODU: ${e.response?.statusCode}");
        print("SUNUCUDAN GELEN YANIT VERİSİ (BODY):");
        print(e.response?.data);
      } else {
        print("Sunucuya ulaşılamadı. İstek gönderilemedi.");
        print("Dio Hata Mesajı: ${e.message}");
      }
      print("--- HATA DETAYLARI SONU ---");
      throw Exception('GIF oluşturulurken bir ağ hatası oluştu. Lütfen daha sonra tekrar deneyin.');

    } catch (e) {
      // Senin genel hata yakalama mekanizman aynı kaldı.
      print("--- !!! BEKLENMEDİK GENEL HATA (catch) !!! ---");
      print("Hata Tipi: ${e.runtimeType}");
      print("Hata Mesajı: $e");
      print("--- HATA DETAYLARI SONU ---");
      throw Exception('Bilinmeyen bir hata oluştu. GIF oluşturulamadı.');
    }
  }
}