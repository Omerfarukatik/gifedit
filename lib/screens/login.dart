// // lib/screens/login.dart
// import 'package:flutter/material.dart';
// import 'signup.dart'; 
// import 'main_screen_wrapper.dart'; 

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.colorScheme.primary;
//     // Temaya duyarlı ana metin rengi
//     final primaryTextColor = theme.textTheme.bodyMedium!.color; 
//     // Sosyal medya butonlarının arka plan rengi (koyu veya açık gri)
//     final socialButtonColor = theme.brightness == Brightness.dark 
//                               ? Colors.white.withOpacity(0.05) 
//                               : Colors.grey.shade100;
//     // İkinci derece metin rengi (Or continue with)
//     final secondaryTextColor = theme.hintColor;


//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView( // TAŞMA HATASI ÇÖZÜLDÜ
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Geri tuşu mantığı (Boşluk bırakıldı)
//                 const SizedBox(height: 56), 
                
//                 Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: primaryTextColor, // TEMA DUYARLI
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 48),

//                 // Email ve Şifre Alanları (Tema tarafından yönetiliyor)
//                 TextFormField(
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 24),
//                 TextFormField(
//                   decoration: const InputDecoration(labelText: 'Password'),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 16),

//                 // Şifremi Unuttum metni
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // TODO: Şifremi unuttum sayfasına geçiş
//                     },
//                     child: Text(
//                       'Forgot Password?',
//                       style: TextStyle(color: primaryColor),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 48),

//                 // Login Butonu (Aynı Kaldı)
//                 ElevatedButton(
//                   onPressed: () {
//                     // TODO: AUTHENTICATION işlemleri buraya gelecek.
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
//                   child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
//                         icon: Icon(Icons.people_alt, color: primaryTextColor), // İkon rengi temadan
//                         label: Text('Google', style: TextStyle(color: primaryTextColor)), // Metin rengi temadan
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

//                 // Hesap Yok Metni (TEMA DUYARLI)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Don't have an account?", style: TextStyle(color: secondaryTextColor)),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const SignupScreen()),
//                         );
//                       },
//                       child: Text('Sign Up', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24), // Alt boşluk
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/signup.dart
// lib/screens/login.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'main_screen_wrapper.dart';
import 'signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final socialButtonColor = theme.brightness == Brightness.dark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.grey.shade100;
    
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
                  l10n.login,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 48),

                // Email alanı
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                
                // Şifre alanı
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Şifremi unuttum metni
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Şifremi unuttum sayfasına geçiş
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Giriş yap butonu
                ElevatedButton(
                  onPressed: () {
                    // TODO: Kimlik doğrulama API'sini çağır
                    
                    // Başarılı girişten sonra ana sayfaya yönlendir
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
                      (Route<dynamic> route) => false, 
                    );
                  },
                  child: Text(l10n.login, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),

                // "Veya şununla devam et" metni
                Row(
                  children: [
                    Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(l10n.orContinueWith, style: TextStyle(color: secondaryTextColor)),
                    ),
                    Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 24),

                // Sosyal medya butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.people_alt, color: primaryTextColor),
                        label: const Text('Google'),
                        style: ElevatedButton.styleFrom(backgroundColor: socialButtonColor, elevation: 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.facebook, color: primaryTextColor),
                        label: const Text('Facebook'),
                        style: ElevatedButton.styleFrom(backgroundColor: socialButtonColor, elevation: 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Hesap yok metni
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.dontHaveAccount, style: TextStyle(color: secondaryTextColor)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Text(l10n.signUp, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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