// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/theme_provider.dart'; 
import 'package:provider/provider.dart';

// --- TEMA VE PROVIDER'LAR ---
import 'package:memecreat/firebase_options.dart';
import 'package:memecreat/theme/app_theme.dart';
import 'package:memecreat/providers/creation_provider.dart'; 
import 'package:memecreat/providers/localization_provider.dart';
import 'package:memecreat/providers/auth_provider.dart'; // AuthProvider eklendi

// --- EKRANLAR ---
import 'package:memecreat/screens/onboarding/splash_screen.dart'; 


void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug,
  appleProvider: AppleProvider.debug,
);  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CreationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), 
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Auth Provider eklendi
      ],
      child: const StitchDesignApp(), 
    ),
  );
}

// Uygulama Başlatıcı (AppInitializer) ve Ana Widget (StitchDesignApp) aynı kalır.
// AppInitializer artık tüm bu 4 provider'ı güvenle okur.

class StitchDesignApp extends StatelessWidget {
  const StitchDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInitializer();
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ları güvenli bir şekilde okuyoruz.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'MEMECREAT AI',
      
      // Tema ayarları
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, 
      
      // Yerelleştirme ayarları
      locale: localeProvider.locale, 
      supportedLocales: const [
        Locale('en', ''), 
        Locale('tr', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}