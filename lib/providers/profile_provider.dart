import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:memecreat/services/storage_service.dart';
import 'package:memecreat/services/user_repository.dart';

class ProfileProvider with ChangeNotifier {
  // --- TEMEL SERVİSLER ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- STREAM DİNLEYİCİLERİ ---
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _userSubscription;
  StreamSubscription? _createdGifsSubscription;
  StreamSubscription? _savedGifsSubscription;

  // --- VERİ ALANLARI ---
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _createdGifs = [];
  List<Map<String, dynamic>> _savedGifs = [];

  // --- DURUM YÖNETİMİ ---
  bool _isLoading = true;
  String? _error;
  final StorageService _storageService = StorageService(); // EKLENDİ
  final UserRepository _userRepository = UserRepository(); // EKLENDİ
  final Set<String> _processingLikes = {}; // EKSİK PARÇA
  final Set<String> _processingSaves = {}; // Kaydetme işlemi için kilit

  // --- GETTER'LAR (ARAYÜZÜN VERİYE ULAŞIM NOKTALARI) ---
  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>> get createdGifs => _createdGifs;
  List<Map<String, dynamic>> get savedGifs => _savedGifs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- CONSTRUCTOR ---
  ProfileProvider() {
    // Sadece bir kere, en başta auth state'i dinle.
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // --- TEMEL MANTIK ---

  // Kullanıcı giriş/çıkış yaptığında tetiklenir.
  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      // Eğer kullanıcı giriş yapmışsa, verilerini dinlemeye başla.
      _listenToProfileData(firebaseUser.uid);
    } else {
      // Eğer kullanıcı çıkış yapmışsa, her şeyi temizle.
      _cancelSubscriptionsAndClearData();
    }
  }

  // Belirtilen kullanıcı ID'si için tüm veritabanı dinleyicilerini başlatır.
  void _listenToProfileData(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Yükleme ekranını göstermek için

    // Yeni bir dinleme başlamadan önce eskileri (varsa) iptal et.
    _cancelSubscriptionsAndClearData(notify: false);

    // Yüklemenin bittiğini anlamak için Completer'lar.
    final userCompleter = Completer<void>();
    final createdGifsCompleter = Completer<void>();
    final savedGifsCompleter = Completer<void>();

    // 1. Kullanıcı verisini dinle
    _userSubscription = _firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      _userData = snapshot.data();
      if (!userCompleter.isCompleted) userCompleter.complete();
      notifyListeners();
    }, onError: (e) => _setError("Kullanıcı verisi alınamadı: $e", userCompleter, e));

    // 2. Oluşturulan GIF'leri dinle
    _createdGifsSubscription = _firestore.collection('users').doc(userId).collection('createdGifs').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _createdGifs = snapshot.docs.map((doc) => doc.data()).toList();
      if (!createdGifsCompleter.isCompleted) createdGifsCompleter.complete();
      notifyListeners();
    }, onError: (e) => _setError("Oluşturulan GIF'ler alınamadı: $e", createdGifsCompleter, e));

    // 3. Kaydedilen GIF'leri dinle
    _savedGifsSubscription = _firestore.collection('users').doc(userId).collection('savedGifs').orderBy('savedAt', descending: true).snapshots().listen((snapshot) {
      _savedGifs = snapshot.docs.map((doc) => doc.data()).toList();
      if (!savedGifsCompleter.isCompleted) savedGifsCompleter.complete();
      notifyListeners();
    }, onError: (e) => _setError("Kaydedilen GIF'ler alınamadı: $e", savedGifsCompleter, e));



    // Tüm dinleyiciler ilk veriyi getirdiğinde yükleme durumunu bitir.
    Future.wait([
      userCompleter.future,
      createdGifsCompleter.future,
      savedGifsCompleter.future,
    ]).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- YARDIMCI METOTLAR (ARAYÜZ İÇİN) ---

  bool isGifSaved(String gifId) => _savedGifs.any((gif) => gif['id'] == gifId);
  bool isProcessingSave(String gifId) => _processingSaves.contains(gifId);

  bool isProcessingLike(String gifId) => _processingLikes.contains(gifId);

  // --- AKSİYONLAR (BUTONLARIN ÇAĞIRDIĞI FONKSİYONLAR) ---

  Future<void> updateUserProfile({
    required String newUsername,
    File? newAvatarFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı girişi yapılmamış.");

    final updateData = <String, dynamic>{};
    bool hasChanges = false;

    // 1. Avatarı güncelle (eğer yeni dosya varsa)
    if (newAvatarFile != null) {
      final path = 'profile_pictures/${user.uid}/avatar.jpg';
      final uploadedUrl = await _storageService.uploadFile(newAvatarFile, path);
      if (uploadedUrl != null) {
        updateData['avatarUrl'] = uploadedUrl;
        hasChanges = true;
      } else {
        throw Exception("Profil fotoğrafı yüklenemedi.");
      }
    }

    // 2. Kullanıcı adını güncelle (eğer değişmişse)
    if (newUsername != _userData?['username']) {
      updateData['username'] = newUsername;
      hasChanges = true;
    }

    // 3. Değişiklik varsa Firestore'a yaz
    if (hasChanges) {
      await _userRepository.updateUserData(user.uid, updateData);
      // Stream zaten dinlediği için notifyListeners() çağırmaya gerek yok,
      // Firestore değişikliği otomatik olarak UI'a yansıtacaktır.
    }
  }

  /// Kullanıcının dil tercihini Firestore'da günceller.
  Future<void> updateUserLanguage(String localeCode) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // settings.locale alanını güncelle
    await _userRepository.updateUserData(user.uid, {'settings.locale': localeCode});
  }

  Future<void> toggleSaveGif(Map<String, dynamic> gifData) async {
    final user = _auth.currentUser;
    final gifId = gifData['id'] as String?;
    if (user == null || gifId == null || isProcessingSave(gifId)) return;

    _processingSaves.add(gifId);
    notifyListeners();

    final docRef = _firestore.collection('users').doc(user.uid).collection('savedGifs').doc(gifId);
    try {
      if (isGifSaved(gifId)) {
        await docRef.delete();
      } else {
        await docRef.set({...gifData, 'savedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      print("toggleSaveGif hatası: $e");
    } finally {
      _processingSaves.remove(gifId);
      notifyListeners();
    }
  }
/// profile_provider.dart dosyasının içindesin.
// Mevcut toggleLikeGif fonksiyonunu sil ve bunu yapıştır.

  Future<void> toggleLikeGif(String gifId) async {
    final user = _auth.currentUser;
    if (user == null || gifId.isEmpty || isProcessingLike(gifId)) return;

    _processingLikes.add(gifId);
    notifyListeners();

    try {
      // ############################################################
      // #        SENİN DAHİCE MİMARİN: DOĞRUDAN GIF'E YAZMAK         #
      // ############################################################

      final gifRef = _firestore.collection('gifs').doc(gifId);
      final userId = user.uid;

      final gifDoc = await gifRef.get();
      if (!gifDoc.exists) {
        throw Exception("GIF bulunamadı: $gifId");
      }

      // `likedBy` listesini al, eğer yoksa boş bir liste oluştur.
      List<dynamic> likedBy = gifDoc.data()?['likedBy'] ?? [];

      if (likedBy.contains(userId)) {
        // Durum: Zaten beğenilmiş -> Beğeniyi Geri Al
        // Kullanıcının ID'sini listeden çıkar.
        await gifRef.update({
          'likedBy': FieldValue.arrayRemove([userId])
        });
        print("Kullanıcı $userId, $gifId beğenisini geri aldı.");
      } else {
        // Durum: Beğenilmemiş -> Beğen
        // Kullanıcının ID'sini listeye ekle.
        await gifRef.update({
          'likedBy': FieldValue.arrayUnion([userId])
        });
        print("Kullanıcı $userId, $gifId GIF'ini beğendi.");
      }

      // ARTIK `likes` SAYACINI MANUEL GÜNCELLEMEYE GEREK YOK!
      // SAYI, `likedBy.length` OLACAK.

    } catch (e) {
      print("toggleLikeGif (Senin Mimarın) hatası: $e");
    } finally {
      _processingLikes.remove(gifId);
      notifyListeners();
    }
  }


  Future<void> refreshData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Zaten var olan, tüm veriyi yeniden çeken ana fonksiyonu çağır.
      _listenToProfileData(user.uid);
    }
  }
  // --- TEMİZLİK ---

  void _setError(String errorMessage, Completer completer, Object error) {
    _error = errorMessage;
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
    _isLoading = false; // Hata durumunda yüklemeyi durdur
    notifyListeners();
  }

  void _cancelSubscriptionsAndClearData({bool notify = true}) {
    // Tüm dinleyicileri iptal et.
    _userSubscription?.cancel();
    _createdGifsSubscription?.cancel();
    _savedGifsSubscription?.cancel();

    // Verileri sıfırla.
    _userData = null;
    _createdGifs = [];
    _savedGifs = [];
    _processingLikes.clear();
    _processingSaves.clear();
    _error = null;

    if (notify) {
      _isLoading = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel(); // Bu en önemlisi
    _cancelSubscriptionsAndClearData(notify: false);
    super.dispose();
  }
}
