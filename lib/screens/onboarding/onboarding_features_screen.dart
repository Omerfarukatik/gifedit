// // lib/screens/onboarding/onboarding_features_screen.dart
// import 'package:flutter/material.dart';

// // Temayı bir üst klasöre çıkıp 'theme' klasöründen alıyoruz.
// import '../../../theme/app_theme.dart'; 
// // Navigasyon için gerekli diğer sayfalar
// import 'onboarding_call_to_action_screen.dart';
// import '../login.dart'; // Eğer Skip butonu Login'e atlayacaksa

// class OnboardingFeaturesScreen extends StatelessWidget {
//   const OnboardingFeaturesScreen({super.key});

//   // Sayfa gösterge nokta widget'ı (main.dart'tan taşındı)
//   Widget _buildDot(BuildContext context, {required bool isSelected}) {
//     final Color primaryColor = AppColors.primary; // AppColors'tan alınıyor
    
//     // Aktif dot: primary, Pasif dot: primary'nin %30'u
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

//   @override
//   Widget build(BuildContext context) {
//     // Renkler AppColors'tan alınıyor
//     final Color primaryColor = AppColors.primary;
//     final Color bodyTextColor = AppColors.contentColor; // Tema tanımındaki onBackground = contentColor

//     return Scaffold(
//       // Scaffold'un arka plan rengi darkTheme'den otomatik geliyor
//       body: SafeArea( 
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // HEADER - Skip Butonu
//             Padding(
//               padding: const EdgeInsets.all(16.0), 
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   TextButton(
//                     onPressed: () {
//                       // Skip mantığı: Onboarding'i atla ve doğrudan Login ekranına git
//                        Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => const LoginScreen()),
//                       );
//                     },
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
//                           _buildDot(context, isSelected: false), // FirstScreen
//                           _buildDot(context, isSelected: true),  // Bu sayfa
//                           _buildDot(context, isSelected: false), // CallToActionScreen
//                         ],
//                       ),
//                     ),

//                     // ************* GÖRSEL ALANI *************
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
//                                     color: AppColors.primary.withOpacity(0.1), // Placeholder Renk
//                                     image: const DecorationImage(
//                                       // Yüklediğiniz görsel yolunu buraya ekleyin:
//                                       image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCaiC1ogUIxNijjFtT8ckT4pUAONiCYZ3wq558j7lFiWssrEaYkNIEQnb4vXlVgWbYu49uuDxMlTosQ138eY7EWUwfzM-ix-icIEfzBJ-Hbk_Toe_mVlD04P2HqFkL9V5YJE-fNHBOT9D4nWQj2G9kK1vzvSb8NcXpPEBGieX761Pi7htsKGhkIyFxcJkBofGpzth9XZPR0T--BafGKKEsyO3B0GIh5oRpxgTr6HJdPR5wXG4zELI2fAxE8aPAIGod7kqVSV-Y-EmHk"),
//                                       fit: BoxFit.cover, 
//                                     ),
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
                    
//                     // Başlık
//                     Padding(
//                       padding: const EdgeInsets.only(top: 32.0, bottom: 16.0), 
//                       child: Text(
//                         'Sadece bir cümle yaz, AI sana görsel ve caption hazırlasın.',
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

//             // FOOTER - Next Butonu
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0), 
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Üçüncü Onboarding sayfasına (Call To Action) geçiş
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const OnboardingCallToActionScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56.0), 
//                 ),
//                 child: const Text(
//                   'Next',
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
// lib/screens/onboarding/onboarding_features_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'onboarding_call_to_action_screen.dart';
import '../login.dart';

class OnboardingFeaturesScreen extends StatelessWidget {
  const OnboardingFeaturesScreen({super.key});

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
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
                    child: Text(l10n.skip, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Görsel Alanı
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Dikey boşluğu azaltarak görseli büyütüyoruz
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/pictures/s2.png', // GÖRSEL YOLU
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                  color: primaryColor.withOpacity(0.2),
                                  child: const Icon(Icons.interests_outlined, size: 80));
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Başlık
                    Text(
                      l10n.memeCreationDescription, // Örnek bir metin key'i
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: primaryTextColor),
                    ),
                    const Spacer(), // Buton ile metin arasına boşluk ekler
                  ],
                ),
              ),
            ),
            Padding( // Buton
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const OnboardingCallToActionScreen()),
                  ),
                  child: Text(l10n.next),
                )),
          ],
        ),
      ),
    );
  }
}