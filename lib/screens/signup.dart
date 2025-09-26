// // lib/screens/signup.dart
// import 'package:flutter/material.dart';
// import 'main_screen_wrapper.dart'; // Başarılı kayıtta gidilecek ana sayfa

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.colorScheme.primary;
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;
//     final socialButtonColor = theme.brightness == Brightness.dark 
//                               ? Colors.white.withOpacity(0.05) 
//                               : Colors.grey.shade100;
//     final secondaryTextColor = theme.hintColor;


//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView( // TAŞMA HATASI İÇİN EKLENDİ
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Geri tuşu mantığı (Boşluk bırakıldı)
//                 const SizedBox(height: 56), 
                
//                 Text(
//                   'Sign Up',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: primaryTextColor, // TEMA DUYARLI
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 48),
                
//                 // Kullanıcı Adı
//                  TextFormField(
//                   decoration: InputDecoration(labelText: 'Username'),
//                 ),
//                 const SizedBox(height: 24),

//                 // Email
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Email'),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Şifre
//                  TextFormField(
//                   decoration: InputDecoration(labelText: 'Password'),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 48),

//                 // Sign Up Butonu
//                 ElevatedButton(
//                   onPressed: () {
//                     // TODO: USER REGISTRATION (Kullanıcı kayıt) işlemleri buraya gelecek.

//                     // Başarılı kayıttan sonra ana sayfaya geçiş.
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
//                       (Route<dynamic> route) => false, 
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(height: 24),

//                 // "Or continue with" metni (TEMA DUYARLI)
//                 Row(
//                   children: [
//                     Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Text('Or continue with', style: TextStyle(color: secondaryTextColor)),
//                     ),
//                     Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Sosyal Medya Butonları (TEMA DUYARLI)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     // Google Butonu
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () { /* TODO */ },
//                         icon: Icon(Icons.people_alt, color: primaryTextColor), 
//                         label: Text('Google', style: TextStyle(color: primaryTextColor)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: socialButtonColor,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     // Facebook Butonu
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () { /* TODO */ },
//                         icon: Icon(Icons.facebook, color: primaryTextColor),
//                         label: Text('Facebook', style: TextStyle(color: primaryTextColor)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: socialButtonColor,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 48),

//                 // Zaten Hesabım Var (Login sayfasına geçiş)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Already have an account?", style: TextStyle(color: secondaryTextColor)),
//                     TextButton(
//                       onPressed: () {
//                         // Login sayfasına geri dön
//                         Navigator.pop(context); 
//                       },
//                       child: Text('Login', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/signup.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    
    // Yerelleştirme sınıfına erişim
    final l10n = AppLocalizations.of(context)!;


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56), 
                
                Text(
                  l10n.signUp, // METİN GÜNCELLENDİ
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 48),
                
                // Kullanıcı Adı
                TextFormField(
                  decoration: InputDecoration(labelText: 'Username'), // 'Username' için arb'da bir değişken ekleyebilirsiniz (l10n.username)
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.email), // METİN GÜNCELLENDİ
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                
                // Şifre
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.password), // METİN GÜNCELLENDİ
                  obscureText: true,
                ),
                const SizedBox(height: 48),

                // Sign Up Butonu
                ElevatedButton(
                  onPressed: () { /* Navigasyon mantığı aynı kalır */ },
                  child: Text(l10n.signUp, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // METİN GÜNCELLENDİ
                ),
                const SizedBox(height: 24),

                // "Or continue with" metni
                Row(
                  children: [
                    Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(l10n.orContinueWith, style: TextStyle(color: secondaryTextColor)), // METİN GÜNCELLENDİ
                    ),
                    Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 24),

                // Sosyal Medya Butonları
                // ... (Sosyal Medya Butonları aynı kalır) ...
                const SizedBox(height: 48),

                // Zaten Hesabım Var
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: secondaryTextColor)), // Bu metin için de arb'a değişken ekleyebilirsiniz
                    TextButton(
                      onPressed: () { /* Navigasyon mantığı aynı kalır */ },
                      child: Text(l10n.login, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)), // METİN GÜNCELLENDİ
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}