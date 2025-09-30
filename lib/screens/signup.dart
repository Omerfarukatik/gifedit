// lib/screens/signup.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/auth_provider.dart';
import 'main_screen_wrapper.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart'; 


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(AuthProvider authProvider, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    
    // AuthProvider üzerinden kayıt işlemini başlat
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
    );

    if (success) {
      // Kayıt başarılı: Alt navigasyonlu ana sayfaya yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
        (Route<dynamic> route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      // Hata oluştuysa, Snackbar ile göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ı dinle
    final authProvider = Provider.of<AuthProvider>(context);
    
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final socialButtonColor = theme.brightness == Brightness.dark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.grey.shade100;
    final secondaryTextColor = theme.hintColor;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56), 
                
                Text(l10n.signUp, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTextColor)),
                const SizedBox(height: 48),
                
                // Kullanıcı Adı
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: l10n.username), // Yerelleştirildi
                  validator: (value) => value!.isEmpty ? l10n.enterUsername : null,
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? l10n.enterEmail : null,
                ),
                const SizedBox(height: 24),
                
                // Şifre
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? l10n.passwordMinLength : null,
                ),
                const SizedBox(height: 48),

                // Sign Up Butonu
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : () => _signUp(authProvider, l10n),
                  child: authProvider.isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(l10n.signUp, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                // ... (Diğer kısımlar aynı kalır) ...
                const SizedBox(height: 48),

                // Zaten Hesabım Var
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount, style: TextStyle(color: secondaryTextColor)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.login, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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