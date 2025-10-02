// lib/screens/login.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <-- 1. GEREKLİ IMPORT
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

  // --- 2. "BENİ HATIRLA" İÇİN YENİ DEĞİŞKENLER ---
  bool _rememberMe = false;
  final _storage = const FlutterSecureStorage();
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadUserCredentials(); // <-- 3. SAYFA YÜKLENİRKEN VERİLERİ ÇEK
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 4. YENİ FONKSİYON: CİHAZDAN KAYITLI BİLGİLERİ YÜKLER ---
  Future<void> _loadUserCredentials() async {
    try {
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');

      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Hata olursa konsola yazdır, uygulamayı kırmasın.
      debugPrint("Güvenli depolamadan veri okunamadı: $e");
    }
  }
  // --------------------------------------------------------

  // --- 5. GİRİŞ İŞLEMİ GÜNCELLENDİ: Bilgileri kaydeder veya siler ---
  Future<void> _signIn(AuthProvider authProvider, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    // Giriş işlemi başlamadan önce bilgileri yönet
    if (_rememberMe) {
      // "Beni Hatırla" seçiliyse, bilgileri güvenli bir şekilde kaydet
      await _storage.write(key: 'email', value: _emailController.text.trim());
      await _storage.write(key: 'password', value: _passwordController.text.trim());
    } else {
      // Seçili değilse, önceden kaydedilmiş tüm bilgileri sil
      await _storage.deleteAll();
    }

    // AuthProvider üzerinden asıl giriş işlemini başlat
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
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
    final l10n = AppLocalizations.of(context)!;

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
                      const SizedBox(height: 10),

                      // --- 6. YENİ WIDGET: "Beni Hatırla" ve "Şifremi Unuttum" ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text(l10n.rememberMe), // <-- l10n dosyanıza 'rememberMe': 'Beni Hatırla' ekleyin
                              value: _rememberMe,
                              onChanged: (newValue) {
                                setState(() {
                                  _rememberMe = newValue ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          TextButton(onPressed: () {}, child: Text(l10n.forgotPassword, style: TextStyle(color: primaryColor))),
                        ],
                      ),
                      // ----------------------------------------------------

                      const SizedBox(height: 32),

                      // Giriş yap butonu
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : () => _signIn(authProvider, l10n),
                        child: authProvider.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.login, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

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
      },
    );
  }
}