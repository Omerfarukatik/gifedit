// // lib/screens/onboarding/onboarding_call_to_action_screen.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // Temayı bir üst klasöre çıkıp 'theme' klasöründen alıyoruz.
// import '../../../theme/app_theme.dart'; 
// // Navigasyon için gerekli diğer sayfalar
// import '../login.dart'; // Gidilecek hedef ekran

// class OnboardingCallToActionScreen extends StatelessWidget {
//   const OnboardingCallToActionScreen({super.key});

//   // Sayfa gösterge nokta widget'ı (Diğer Onboarding sayfalarındaki gibi)
//   Widget _buildDot(BuildContext context, {required bool isSelected}) {
//     final Color primaryColor = AppColors.primary;
    
//     Color dotColor = isSelected ? primaryColor : primaryColor.withOpacity(0.3);

//     return Container(
//       width: 8.0, 
//       height: 8.0, 
//       margin: const EdgeInsets.symmetric(horizontal: 4.0), 
//       decoration: BoxDecoration(
//         shape: BoxShape.circle, 
//         color: dotColor,
//       ),
//     );
//   }

// void _navigateToLogin(BuildContext context) async {
//     // --------------------------------------------------------------------
//     // YENİ MANTIK: Onboarding'in tamamlandığını kaydediyoruz.
//     // --------------------------------------------------------------------
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_seen_onboarding', true);
    
//     // Geçmişi temizleyerek Login ekranına geçiş
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//         (Route<dynamic> route) => false,
//     );
// }
//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = AppColors.primary;
//     final Color bodyTextColor = AppColors.contentColor;

//     return Scaffold(
//       body: SafeArea( 
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // HEADER - Skip Butonu (GÜNCELLENDİ)
//             Padding(
//               padding: const EdgeInsets.all(16.0), 
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   TextButton(
//                     onPressed: () => _navigateToLogin(context), // Aynı navigasyon fonksiyonu
//                     child: Text(
//                       'Skip',
//                       style: TextStyle(
//                         color: primaryColor,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.25,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // MAIN CONTENT
//             Expanded( 
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0), 
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center, 
//                   children: <Widget>[
//                     // Sayfa Göstergeleri
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 20.0), 
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           _buildDot(context, isSelected: false), 
//                           _buildDot(context, isSelected: false), 
//                           _buildDot(context, isSelected: true), // Bu sayfa aktif
//                         ],
//                       ),
//                     ),

//                     // ************* GÖRSEL ALANI ************* (Placeholder)
//                     // ... (Görsel ve Gölge kodları aynı kalır) ...
//                     Flexible(
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 384.0),
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             return Container(
//                               height: constraints.maxHeight,
//                               child: AspectRatio(
//                                 aspectRatio: 9 / 16,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(16.0),
//                                     color: AppColors.primary.withOpacity(0.1),
//                                     boxShadow: [
//                                         BoxShadow(
//                                           color: AppColors.primary.withOpacity(0.4),
//                                           blurRadius: 40,
//                                           spreadRadius: 2,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }
//                         ),
//                       ),
//                     ),

//                     // Başlık (Aynı Kalır)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 32.0, bottom: 16.0), 
//                       child: Text(
//                         'Artık hazırsın! Hemen giriş yap ve ilk GIF\'ini oluştur.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 24.0, 
//                           fontWeight: FontWeight.bold, 
//                           height: 1.25, 
//                           color: bodyTextColor, 
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // FOOTER - Başla Butonu (GÜNCELLENDİ)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0), 
//               child: ElevatedButton(
//                 onPressed: () => _navigateToLogin(context), // Aynı navigasyon fonksiyonu
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56.0), 
//                 ),
//                 child: const Text(
//                   'Başla',
//                   style: TextStyle(
//                     fontSize: 16.0, 
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/onboarding/onboarding_call_to_action_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';

class OnboardingCallToActionScreen extends StatelessWidget {
  const OnboardingCallToActionScreen({super.key});

  void _navigateToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryTextColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => _navigateToLogin(context),
                    child: Text(l10n.skip, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(l10n.readyToStart, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor)), // Örnek metin
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: ElevatedButton(
                onPressed: () => _navigateToLogin(context),
                child: Text(l10n.start, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Örnek metin
              ),
            ),
          ],
        ),
      ),
    );
  }
}