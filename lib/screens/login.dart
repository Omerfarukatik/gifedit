// lib/screens/login.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Yerel Importlar
import '../../providers/auth_provider.dart'; 
import 'main_screen_wrapper.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller'lar ve Form Anahtarı
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş İşlemi (Provider'ı çağırır ve sonucu yönetir)
  Future<void> _signIn(AuthProvider authProvider, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    
    // AuthProvider üzerinden giriş işlemini başlat
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success) {
      // Giriş başarılı: Alt navigasyonlu ana sayfaya yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
        (Route<dynamic> route) => false,
      );
    } else if (authProvider.errorMessage != null && mounted) {
      // Hata oluştuysa, Snackbar ile kullanıcı dostu mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final socialButtonColor = theme.brightness == Brightness.dark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.grey.shade100;
    final l10n = AppLocalizations.of(context)!;

    // ANA WIDGET: Consumer ile AuthProvider'ı güvenli bir şekilde alıyoruz
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form( 
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 56), 
                      
                      Text(l10n.login, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const SizedBox(height: 48),

                      // Email alanı
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: l10n.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? l10n.enterEmail : null,
                      ),
                      const SizedBox(height: 24),
                      
                      // Şifre alanı
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: l10n.password),
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? l10n.passwordMinLength : null,
                      ),
                      const SizedBox(height: 16),

                      // Şifremi unuttum metni
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: Text(l10n.forgotPassword, style: TextStyle(color: primaryColor))),
                      ),
                      const SizedBox(height: 48),

                      // Giriş yap butonu
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : () => _signIn(authProvider, l10n),
                        child: authProvider.isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : Text(l10n.login, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      
                      // ... (Sosyal medya ve kaydol kısımları) ...
                      const SizedBox(height: 48),

                      // Hesap yok metni
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.dontHaveAccount, style: TextStyle(color: secondaryTextColor)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
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
          ),
        );
      }
    );
  }
}