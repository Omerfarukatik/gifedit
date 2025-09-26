// import 'package:flutter/material.dart';
// import 'package:memecreat/screens/onboarding/onboarding_features_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Meme Generator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const OnboardingWelcomeScreen(),
//     );
//   }
// }

// class OnboardingWelcomeScreen extends StatelessWidget {
//   const OnboardingWelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A121F),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   // Help button in top-right corner
//                   Positioned(
//                     top: 20,
//                     right: 20,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade800.withOpacity(0.5),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Center(
//                         child: Text(
//                           '?',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // Main content
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Portrait frame
//                         Container(
//                           width: 300,
//                           height: 400,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Center(
//                             child: Container(
//                               width: 250,
//                               height: 350,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 10,
//                                     offset: const Offset(5, 5),
//                                   ),
//                                 ],
//                               ),
//                               child: Stack(
//                                 children: [
//                                   // Yellow background
//                                   Container(
//                                     color: const Color(0xFFFEDC7C),
//                                   ),
                                  
//                                   // Portrait illustration
//                                   Center(
//                                     child: Image.asset(
//                                       'resimler/1.png',
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return Container(
//                                           color: const Color(0xFFFEDC7C),
//                                           child: const Center(
//                                             child: Icon(
//                                               Icons.person,
//                                               size: 100,
//                                               color: Color(0xFFE78F5E),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
                        
//                         const SizedBox(height: 60),
                        
//                         // Text in Turkish
//                         const Text(
//                           'AI ile anında meme üret!',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Bottom section with button and dots
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//               child: Column(
//                 children: [
//                   // Purple button
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                           MaterialPageRoute(builder: (context) => const OnboardingFeaturesScreen()),
//               );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFB23FD8),
//                       minimumSize: const Size(double.infinity, 60),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text(
//                       'Başla',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Pagination dots
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFB23FD8),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade600,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade600,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/onboarding/onboarding_welcome_screen.dart
// lib/screens/onboarding/onboarding_welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'onboarding_features_screen.dart';
import '../login.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
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
              child: Center(
                child: Text(l10n.welcomeTitle, style: TextStyle(fontSize: 24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingFeaturesScreen()),
                ),
                child: Text(l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}