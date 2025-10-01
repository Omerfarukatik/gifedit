import 'dart:async'; // StreamSubscription için gerekli
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _userSubscription;
  StreamSubscription? _createdGifsSubscription;
  StreamSubscription? _savedGifsSubscription;

  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _createdGifs = [];
  List<Map<String, dynamic>> _savedGifs = [];
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>> get createdGifs => _createdGifs;
  List<Map<String, dynamic>> get savedGifs => _savedGifs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToProfileData(user.uid);
      } else {
        _cancelSubscriptionsAndClearData();
      }
    });
  }

  void _listenToProfileData(String userId) {
    // Sadece ilk defa dinleme başlarken yükleme durumunu ayarla
    if (_userData == null) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    _cancelSubscriptionsAndClearData(notify: false);

    // --- YENİ VE BASİTLEŞTİRİLMİŞ MANTIK ---

    // Her stream'den gelen cevabı birleştirmek için Completer kullanalım.
    // Bu, üç stream de ilk verilerini getirdiğinde emin olmamızı sağlar.
    final userCompleter = Completer<void>();
    final createdGifsCompleter = Completer<void>();
    final savedGifsCompleter = Completer<void>();

    // 1. Kullanıcı verisini dinle
    _userSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = snapshot.data();
      }
      if (!userCompleter.isCompleted) userCompleter.complete();
      // Her güncellemede dinleyicileri uyar
      notifyListeners();
    }, onError: (e) {
      _error = "Kullanıcı verisi dinlenirken hata: $e";
      if (!userCompleter.isCompleted) userCompleter.completeError(e);
      notifyListeners();
    });

    // 2. Oluşturulan GIF'leri dinle
    _createdGifsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('createdGifs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _createdGifs = snapshot.docs.map((doc) => doc.data()).toList();
      if (!createdGifsCompleter.isCompleted) createdGifsCompleter.complete();
      // Her güncellemede dinleyicileri uyar
      notifyListeners();
    }, onError: (e) {
      _error = "Oluşturulan GIF'ler dinlenirken hata: $e";
      if (!createdGifsCompleter.isCompleted) createdGifsCompleter.completeError(e);
      notifyListeners();
    });

    // 3. Kaydedilen GIF'leri dinle
    _savedGifsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('savedGifs')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _savedGifs = snapshot.docs.map((doc) => doc.data()).toList();
      if (!savedGifsCompleter.isCompleted) savedGifsCompleter.complete();
      // Her güncellemede dinleyicileri uyar
      notifyListeners();
    }, onError: (e) {
      print("Kaydedilen GIF'ler dinlenirken hata oluştu: $e");
      if (!savedGifsCompleter.isCompleted) savedGifsCompleter.completeError(e);
    });

    // Üç stream de ilk cevabını verdiğinde, _isLoading durumunu false yap.
    Future.wait([
      userCompleter.future,
      createdGifsCompleter.future,
      savedGifsCompleter.future,
    ]).then((_) {
      if (_isLoading) {
        _isLoading = false;
        // Yükleme bittiğinde son bir kez daha güncelle
        notifyListeners();
      }
    }).catchError((_) {
      // Bir hata oluşsa bile yükleme durumunu kapat.
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> refreshData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _listenToProfileData(user.uid);
    }
  }

  void _cancelSubscriptionsAndClearData({bool notify = true}) {
    _userSubscription?.cancel();
    _createdGifsSubscription?.cancel();
    _savedGifsSubscription?.cancel();

    // Verileri null/boş yap, ama isLoading'i hemen değiştirme
    _userData = null;
    _createdGifs = [];
    _savedGifs = [];
    _error = null;

    if (notify) {
      _isLoading = true; // Temizlendiğinde tekrar yükleme moduna geç
      notifyListeners();
    }
  }
  // Bir GIF'in kayıtlı olup olmadığını kontrol eden yardımcı fonksiyon.
  bool isGifSaved(String gifId) {
    // _savedGifs listesindeki map'lerin 'id' key'ine bakarak kontrol et.
    return _savedGifs.any((gif) => gif['id'] == gifId);
  }

  // BİR GIF'İ KAYDETME VEYA KAYITTAN ÇIKARMA FONKSİYONU
  Future<void> toggleSaveGif(Map<String, dynamic> gifData) async {
    final user = _auth.currentUser;
    if (user == null) return; // Kullanıcı giriş yapmamışsa hiçbir şey yapma

    final gifId = gifData['id'];
    if (gifId == null) return; // GIF ID'si yoksa işlem yapma

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedGifs')
        .doc(gifId);

    try {
      if (isGifSaved(gifId)) {
        // Eğer GIF zaten kayıtlıysa, sil.
        await docRef.delete();
        print("GIF kayıtlardan çıkarıldı: $gifId");
      } else {
        // Eğer kayıtlı değilse, ekle.
        // Kaydedilme zamanını da ekleyelim ki sıralama doğru çalışsın.
        await docRef.set({
          ...gifData,
          'savedAt': FieldValue.serverTimestamp(),
        });
        print("GIF kaydedildi: $gifId");
      }
      // Not: `listenToData` canlı dinleme yaptığı için, bu işlemden sonra
      // `_savedGifs` listesi otomatik olarak güncellenecek ve `notifyListeners`
      // tetiklenecektir. Bizim burada tekrar `notifyListeners` çağırmamıza gerek yok.
    } catch (e) {
      print("GIF kaydetme işlemi başarısız: $e");
      // Hata durumunda kullanıcıya bir geri bildirim verilebilir.
    }
  }
  @override
  void dispose() {
    _cancelSubscriptionsAndClearData(notify: false);
    super.dispose();
  }
}
