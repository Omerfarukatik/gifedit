// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Tema modunu kaydetmek için kullanılan anahtar
  static const String _themeModeKey = 'themeMode';

  // Varsayılan tema: Sistem Ayarı
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    // Uygulama açıldığında kayıtlı modu yükler
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kayıtlı tema modunu index olarak oku (Kaydı yoksa ThemeMode.system'ı kullan)
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    
    // Index'in geçerli olduğundan emin ol
    if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
    } else {
        _themeMode = ThemeMode.system; 
    }
    
    // Dinleyen tüm widget'ları bilgilendir
    notifyListeners(); 
  }

  // Yeni temayı ayarlar ve kaydeder (Profil ekranında kullanılır)
  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; 

    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
    
    notifyListeners();
  }
}