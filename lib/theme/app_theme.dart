// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// -----------------------------------------------------------------
// 1. RENK TANIMLARI (AppColors sınıfı)
// -----------------------------------------------------------------

class AppColors {
  // Mevcut main.dart dosyanızdan alınan renkler
  static const Color primary = Color(0xFFB613EC); // Mor Vurgu
  static const Color backgroundDark = Color(0xFF1D1022); // Koyu Arka Plan
  static const Color contentColor = Color(0xFFFFFFFF); // Beyaz İçerik (Koyu Temada)
  static const Color secondaryContentColor = Color(0xFFE0E0E0); // Gri İçerik

  // İleride Light/Açık Tema için kullanılacak renkler:
  static const Color backgroundLight = Color(0xFFF0F0F0); 
  static const Color contentColorLight = Color(0xFF333333); 
  static const Color cardColorLight = Color(0xFFFFFFFF); // Açık tema için kart rengi
}

// Ana renk paleti oluşturulur (MaterialApp için gerekli)
final MaterialColor primarySwatch = MaterialColor(AppColors.primary.value, {
  50: AppColors.primary.withOpacity(0.1),
  100: AppColors.primary.withOpacity(0.2),
  500: AppColors.primary,
  700: AppColors.primary,
});


// -----------------------------------------------------------------
// 2. TEMA TANIMLARI (Dark Theme)
// -----------------------------------------------------------------

class AppTheme {

  // Koyu Tema Ayarları
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark, 
    fontFamily: 'Plus Jakarta Sans', 
    
    // ColorScheme
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: primarySwatch,
      brightness: Brightness.dark,
      backgroundColor: AppColors.backgroundDark,
    ).copyWith(
      primary: AppColors.primary,
      onBackground: AppColors.contentColor, 
    ),
    
    // ElevatedButton Teması (Sizin projenizden alındı)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, 
        foregroundColor: Colors.white,
        shadowColor: AppColors.primary.withOpacity(0.3), 
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    ),

    // System UI Overlay Ayarları (Status bar, Nav bar rengi)
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.backgroundDark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.backgroundDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
  );
  
static final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  fontFamily: 'Plus Jakarta Sans', 
  
  // ----------------------------------------------------
  // YENİ EKLENEN/GÜNCELLENEN KISIMLAR
  // ----------------------------------------------------
  
  // 1. GENEL METİN TEMASI (TEXT THEME)
  // Scaffold'daki Text widget'larının varsayılan rengini belirler.
  textTheme: Typography.blackMountainView.copyWith(
    bodyMedium: TextStyle(color: AppColors.contentColorLight),
    bodyLarge: TextStyle(color: AppColors.contentColorLight),
    titleMedium: TextStyle(color: AppColors.contentColorLight),
    titleLarge: TextStyle(color: AppColors.contentColorLight),
    headlineMedium: TextStyle(color: AppColors.contentColorLight),
  ),
  
  // 2. GENEL İKON TEMASI (ICON THEME)
  iconTheme: const IconThemeData(
    color: AppColors.contentColorLight, // İkonları koyu yapar
  ),
  
  // ColorScheme (Aynı Kaldı)
  colorScheme: ColorScheme.fromSwatch(
    // ...
  ).copyWith(
    primary: AppColors.primary, 
    onBackground: AppColors.contentColorLight, // Metin siyah
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white, // Kutu içini saf beyaz yapalım
    
    // Kenarlık rengini gri ile belirginleştirme
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0), // rounded-xl ile uyumlu
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Hafif gri kenarlık
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: AppColors.primary, width: 2.0), // Mor odaklanma
    ),
    // Varsayılan kenarlık stili (border: OutlineInputBorder yerine geçiyor)
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    
    labelStyle: TextStyle(color: AppColors.contentColorLight.withOpacity(0.7)),
    hintStyle: TextStyle(color: AppColors.contentColorLight.withOpacity(0.5)),
  ),
  
  // Açık temada AppBar'ın görünümü
  appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight, 
      // AppBar üzerindeki metin ve ikonları koyu yapıyoruz
      foregroundColor: AppColors.contentColorLight, 
      elevation: 1, // Hafif bir gölge ekleyerek içeriği ayırıyoruz
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundLight,
        statusBarIconBrightness: Brightness.dark, // İkonlar koyu
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
      
  // Buton teması koyu temadaki ile aynıdır (mor vurgu)
  elevatedButtonTheme: darkTheme.elevatedButtonTheme, 
);

}