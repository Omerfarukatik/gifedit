// // lib/screens/splash_screen.dart

// import 'package:flutter/material.dart';
// import 'package:memecreat/screens/login.dart';
// import 'package:memecreat/screens/onboarding/onboarding_welcome_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Bu paketi eklemelisiniz
//  // Oturumu kapalı olanların gideceği yer

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {

//   @override
//   void initState() {
//     super.initState();
//     _checkUserStatus();
//   }

//   void _checkUserStatus() async {
//     // Shared Preferences (Tercihler) ile kontrol yapıyoruz
//     final prefs = await SharedPreferences.getInstance();
    
//     // Uygulamanın daha önce açılıp açılmadığını kontrol eden bir anahtar
//     const hasSeenOnboardingKey = 'has_seen_onboarding';
    
//     // Basitleştirilmiş Oturum Kontrolü (Sizin gerçek uygulamanızda bir token kontrolü olacaktır)
//     const isLoggedInKey = 'is_logged_in'; 
//     bool isLoggedIn = prefs.getBool(isLoggedInKey) ?? false;
    
//     // Uygulama açılışını 2 saniye bekletelim
//     await Future.delayed(const Duration(seconds: 2));

//     Widget nextScreen;

//     if (isLoggedIn) {
//       // Varsayım: Giriş yapmış kullanıcı. Direkt Ana Sayfaya
//       // Buraya MainScreenWrapper gelmeli, ancak Login'e yönlendirelim şimdilik
//       nextScreen = const LoginScreen(); // Buraya MainScreenWrapper() gelmeli.
//     } else if (prefs.getBool(hasSeenOnboardingKey) == true) {
//       // Onboarding'i görmüş ama oturumu kapalı. Login'e
//       nextScreen = const LoginScreen();
//     } else {
//       // Yeni kullanıcı. Onboarding'e
//       nextScreen = const OnboardingWelcomeScreen(); // Onboarding akışının ilk sayfası
//     }

//     // Geçmişi temizleyerek (pushReplacement) yönlendirme
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => nextScreen),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Basit bir karşılama ekranı
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'FARUK ATİK',
//           style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/onboarding/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_screen_wrapper.dart';
import '../login.dart';
import 'onboarding_welcome_screen.dart'; // Onboarding akışının ilk sayfası

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    // SharedPreferences başlatılıyor
    final prefs = await SharedPreferences.getInstance();
    
    // Uygulama açılışını 2 saniye bekletelim (Logo gösterimi için)
    await Future.delayed(const Duration(seconds: 2));

    const hasSeenOnboardingKey = 'has_seen_onboarding';
    // Gerçek uygulamada burası token kontrolü olacaktır
    const isLoggedInKey = 'is_logged_in'; 

    bool hasSeenOnboarding = prefs.getBool(hasSeenOnboardingKey) ?? false;
    bool isLoggedIn = prefs.getBool(isLoggedInKey) ?? false; // Varsayılan: false

    Widget nextScreen;

    if (isLoggedIn) {
      // Oturumu açıksa direkt Ana Sayfa'ya (MainScreenWrapper)
      nextScreen = const MainScreenWrapper();
    } else if (hasSeenOnboarding) {
      // Onboarding'i görmüş ama oturumu kapalıysa Login'e
      nextScreen = const LoginScreen();
    } else {
      // Yeni kullanıcı ise Onboarding'e
      nextScreen = const OnboardingWelcomeScreen();
    }

    // Geriye dönüşü engelliyoruz
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => nextScreen),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash ekranınızın tasarımı. Tema rengini otomatik alacaktır.
    return const Scaffold(
      body: Center(
        child: Text(
          'MEMECREAT AI', // Splash ekran metniniz
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}