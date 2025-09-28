// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memecreat/firebase_options.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/provider/localization_provider.dart';
import 'package:memecreat/provider/creation_provider.dart';
import 'package:memecreat/provider/theme_provider.dart';
import 'package:provider/provider.dart';

// --- YERELLEŞTİRME VE TEMA ---
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:memecreat/theme/app_theme.dart';
 

// --- PROVIDER VE SERVİSLER ---


// --- EKRANLAR (ONBOARDING, AUTH, NAVİGASYON) ---
import 'package:memecreat/screens/onboarding/splash_screen.dart'; 


// -----------------------------------------------------------------
// 1. ANA FONKSİYON VE GLOBAL PROVIDER YAPISI
// -----------------------------------------------------------------
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // MultiProvider, tüm sağlayıcıları uygulamanın en üst seviyesine taşır.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CreationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), 
      ],
      // StitchDesignApp, MultiProvider'ın çocuğudur.
      child: const StitchDesignApp(), 
    ),
  );
}

// -----------------------------------------------------------------
// 2. ANA UYGULAMA WIDGET'I (ROOT WIDGET)
// -----------------------------------------------------------------
class StitchDesignApp extends StatelessWidget {
  const StitchDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    // StitchDesignApp, sadece AppInitializer'ı döndürür.
    return const AppInitializer();
  }
}


// -----------------------------------------------------------------
// 3. UYGULAMA BAŞLATICI (SAFE PROVIDER READER)
// -----------------------------------------------------------------
// Bu widget, Provider'ları güvenli bir şekilde okur ve MaterialApp'i döndürerek 
// ProviderNotFoundException hatasını çözer.
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ları güvenli bir şekilde okuyoruz. Bu BuildContext, MultiProvider'ın altındadır.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'MEMECREAT AI',
      
      // TEMA AYARLARI
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, 
      
      // YERELLEŞTİRME AYARLARI
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