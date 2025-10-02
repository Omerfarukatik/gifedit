import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/theme_provider.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/screens/subscriptions_screen.dart';
import 'package:memecreat/providers/auth_provider.dart';
import 'package:memecreat/screens/login.dart';
import 'package:memecreat/screens/edit_profile_screen.dart';
import 'package:memecreat/providers/localization_provider.dart';

// Ekran artık `StatelessWidget`, çünkü durumu Provider yönetiyor.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ProfileProvider'ı dinle. Değişiklik olduğunda bu widget yeniden çizilecek.
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Durum 1: Veriler yükleniyor
        if (profileProvider.isLoading && profileProvider.userData == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.profile)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Durum 2: Bir hata oluştu veya kullanıcı giriş yapmamış
        if (profileProvider.error != null || profileProvider.userData == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.profile)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  profileProvider.error ?? l10n.pleaseLoginToSeeProfile,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Durum 3: Veriler başarıyla geldi, arayüzü çiz
        final userData = profileProvider.userData!;

        return Scaffold(
            appBar: AppBar(
              title: Text(l10n.profile),
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => profileProvider.refreshData(), // Ekranı aşağı çekerek yenileme
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. Üst Bölüm: Dinamik Avatar ve İstatistikler
                    _ProfileHeader(userData: userData),

                    const Divider(height: 1),

                    // 2. ABONELİK AYARLARI KARTI
                    const _SubscriptionSettingsCard(),
                    const Divider(height: 1),

                    // 3. GÖRÜNÜM AYARLARI
                    const _ThemeSettingsWidget(),
                    const Divider(height: 1),

                    // 4. DİL AYARLARI
                    const _LanguageSettingsWidget(),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}

/// Çıkış yapma işlemi için onay diyaloğu gösterir.
Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  // Diyalog gösterilmeden önce l10n ve provider'ları alalım.
  final l10n = AppLocalizations.of(context)!;
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(l10n.logOut),
        content: const Text("Çıkış yapmak istediğinizden emin misiniz?"), // TODO: Yerelleştir
        actions: <Widget>[
          TextButton(
            child: const Text("Vazgeç"), // TODO: Yerelleştir
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Sadece diyaloğu kapat
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.logOut),
            onPressed: () async {
              // Önce diyaloğu kapat
              Navigator.of(dialogContext).pop();

              // Sonra çıkış işlemini gerçekleştir
              await authProvider.signOut();

              // Ana widget'ın hala ekranda olduğundan emin ol
              if (!context.mounted) return;

              // Kullanıcıyı giriş ekranına yönlendir ve geri dönememesini sağla
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}
/// Profil ekranı için Dil Ayarları widget'ı.
class _LanguageSettingsWidget extends StatelessWidget {
  const _LanguageSettingsWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final currentLocale = localeProvider.locale;

    void changeLocale(String languageCode) {
      // Hem lokal state'i hem de veritabanını güncelle
      localeProvider.setLocale(Locale(languageCode));
      profileProvider.updateUserLanguage(languageCode);
    }

    return ExpansionTile(
      leading: const Icon(Icons.language_outlined, size: 28),
      title: const Text(
        "Dil Ayarları", // TODO: Yerelleştir
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        RadioListTile<String>(
          title: const Text('Türkçe'),
          value: 'tr',
          groupValue: currentLocale.languageCode,
          onChanged: (value) {
            if (value != null) {
              changeLocale(value);
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('English'),
          value: 'en',
          groupValue: currentLocale.languageCode,
          onChanged: (value) {
            if (value != null) {
              changeLocale(value);
            }
          },
        ),
      ],
    );
  }
}


class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _ProfileHeader({required this.userData});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final secondaryTextColor = theme.hintColor;

    // Verileri Map'ten al
    final username = userData['username'] ?? l10n.username;
    final avatarUrl = userData['avatarUrl'] as String?; // 'avatar_url' -> 'avatarUrl' olarak düzeltildi
    final stats = userData['stats'] as Map<String, dynamic>? ?? {};
    final creationsCount = stats['creationsCount'] ?? 0;
    final totalLikes = stats['totalLikes'] ?? 0;
    final followerCount = stats['followers'] ?? 0; // DB'den gelen 'followers'

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            username,
            style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium!.color),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(label: l10n.gifStat, value: creationsCount),
              _StatColumn(label: l10n.likeStat, value: totalLikes),
              _StatColumn(label: l10n.followerStat, value: followerCount),
            ],
          ),
          const SizedBox(height: 20),
          // Profili Düzenle Butonu
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userData: userData),
                ),
              );
            },
            child: const Text("Profili Düzenle"), // TODO: Yerelleştir
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: theme.hintColor),
        ),
      ],
    );
  }
}

/// Profil ekranında abonelik durumunu gösteren ve detay sayfasına yönlendiren kart.
class _SubscriptionSettingsCard extends StatelessWidget {
  const _SubscriptionSettingsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionsScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_outlined, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscriptionManagement,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.currentPlanTitle, // "Mevcut Planınız: Stitch PRO"
                    style: TextStyle(color: theme.hintColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}


/// Profil ekranı için Görünüm Ayarları widget'ı.
class _ThemeSettingsWidget extends StatelessWidget {
  const _ThemeSettingsWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final currentMode = themeProvider.themeMode;
    final isSystem = currentMode == ThemeMode.system;
    final isDark = currentMode == ThemeMode.dark;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;

    return ExpansionTile(
      leading: Icon(Icons.palette_outlined, color: primaryTextColor, size: 28),
      title: Text(
        l10n.appearanceSettings,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      initiallyExpanded: true, // Bu bölümün başlangıçta açık gelmesini sağlar.
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero, // Kenar boşluklarını sıfırla
            title: Text(
              l10n.darkMode,
              style: TextStyle(color: primaryTextColor),
            ),
            subtitle: Text(
              isDark ? "Koyu mod aktif" : "Açık mod aktif", // TODO: Yerelleştir
              style: TextStyle(color: secondaryTextColor),
            ),
            value: isDark,
            onChanged: (isNowDark) {
              themeProvider.setThemeMode(isNowDark ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
      ],
    );
  }
}
