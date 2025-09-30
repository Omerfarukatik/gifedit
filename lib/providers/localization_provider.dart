// lib/providers/localization_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BU TANIMIN DOĞRU VE TAM OLDUĞUNDAN EMİN OLUN
class LocaleProvider with ChangeNotifier { 
  static const String _languageCodeKey = 'languageCode';
  
  Locale _locale = const Locale('tr', ''); 

  Locale get locale => _locale;

  LocaleProvider() {
    _loadPreferredLocale();
  }

void _loadPreferredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Kullanıcının daha önce kaydettiği bir dil kodu var mı?
    final savedLanguageCode = prefs.getString(_languageCodeKey);
    
    if (savedLanguageCode != null) {
      // 2. Evet ise, kaydedilen dili kullan.
      _locale = Locale(savedLanguageCode, '');
    } else {
      // 3. Hayır ise, cihazın kendi dilini kullan.
      // WidgetsBinding'in başlatıldığından emin olmalıyıyız.
      // platformDispatcher.locale, cihazın dilini verir.
      final deviceLocaleCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      
      // Uygulamanın desteklediği diller arasında bir kontrol yap.
      // Basitçe cihaz dilini kullanıyoruz:
      _locale = Locale(deviceLocaleCode, ''); 
    }
    
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    
    notifyListeners();
  }
}