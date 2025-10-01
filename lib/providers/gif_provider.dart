import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GifProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _gifsSubscription;

  List<Map<String, dynamic>> _gifs = [];
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> get gifs => _gifs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Provider oluşturulduğunda hemen GIF'leri dinlemeye başla.
  GifProvider() {
    listenToGifs();
  }

  void listenToGifs() {
    _isLoading = true;
    notifyListeners();

    _gifsSubscription = _firestore
        .collection('gifs') // Ana 'gifs' koleksiyonunu dinliyoruz
        .orderBy('createdAt', descending: true) // En yeni olanlar en üstte
        .limit(20) // Performans için şimdilik son 20 GIF'i alalım
        .snapshots() // Canlı dinleme
        .listen((snapshot) {
      _gifs = snapshot.docs.map((doc) {
        // Her dokümana kendi ID'sini de ekleyelim, ileride lazım olacak (like vs.)
        return {'id': doc.id, ...doc.data()};
      }).toList();
      _isLoading = false;
      _error = null;
      notifyListeners(); // Arayüze "veri geldi, güncelle" de
    }, onError: (e) {
      _error = "GIF akışı alınırken bir hata oluştu: $e";
      _isLoading = false;
      notifyListeners(); // Arayüze "hata var, güncelle" de
    });
  }

  // Provider hafızadan silinirken dinleyiciyi kapat (hafıza sızıntısını önler)
  @override
  void dispose() {
    _gifsSubscription?.cancel();
    super.dispose();
  }
}
