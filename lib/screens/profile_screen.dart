import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/theme_provider.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/screens/subscriptions_screen.dart';

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
        final createdGifs = profileProvider.createdGifs;
        final savedGifs = profileProvider.savedGifs;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.profile),
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubscriptionsScreen()),
                    );
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => profileProvider.refreshData(), // Ekranı aşağı çekerek yenileme
              child: Column(
                children: [
                  // 1. Üst Bölüm: Dinamik Avatar ve İstatistikler
                  _ProfileHeader(userData: userData),

                  // 2. TEMA AYARLARI
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: _ThemeToggle(),
                  ),
                  const Divider(height: 1),

                  // 3. TabBar (Sekmeli Menü)
                  _TabBar(l10n: l10n),

                  // 4. İçerik Akışı (Sekme İçeriği)
                  Expanded(
                    child: TabBarView(
                      children: [
                        // #################### ASIL DÜZELTME BURADA ####################
                        _GifGrid(
                          // KEY'e listenin uzunluğunu ekliyoruz.
                          // Bu, liste uzunluğu değiştiğinde Flutter'a "Bu YEPYENİ bir widget" der.
                            key: ValueKey('created_gifs_${createdGifs.length}'),
                            gifs: createdGifs,
                            noContentMessage: l10n.noGifsCreatedYet
                        ),
                        _GifGrid(
                          // Aynısını kaydedilenler için de yapalım.
                            key: ValueKey('saved_gifs_${savedGifs.length}'),
                            gifs: savedGifs,
                            noContentMessage: l10n.noGifsSavedYet
                        ),
                        // #################################################################
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


// --- ARAYÜZ PARÇALARI (DEĞİŞİKLİK YOK, AMA TAM KOD İÇİN BURADALAR) ---

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _ProfileHeader({required this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final secondaryTextColor = theme.hintColor;

    // Verileri Map'ten al
    final username = userData['username'] ?? l10n.username;
    final avatarUrl = userData['avatar_url'] as String?;
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

class _TabBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  const _TabBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TabBar(
      indicatorColor: theme.colorScheme.primary,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.hintColor,
      tabs: [
        Tab(text: l10n.created, icon: const Icon(Icons.grid_on)),
        Tab(text: l10n.saved, icon: const Icon(Icons.bookmark)),
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GifGrid extends StatelessWidget {
  final List<Map<String, dynamic>> gifs;
  final String noContentMessage;
  // super.key'i GridView.builder'a aktarıyoruz.
  const _GifGrid({super.key, required this.gifs, required this.noContentMessage});

  @override
  Widget build(BuildContext context) {
    if (gifs.isEmpty) {
      return Center(child: Text(noContentMessage));
    }
    return GridView.builder(
      key: key, // Bu, widget'ın kendi key'ini (ValueKey) GridView'e aktarır.
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: gifs.length,
      itemBuilder: (context, index) {
        final gifData = gifs[index];
        final gifUrl = gifData['gifUrl'] as String?;
        if (gifUrl == null) return Container(color: Colors.red.shade100);

        return ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: CachedNetworkImage(
            // Her bir resme de kendi URL'sinden oluşan eşsiz bir key verelim.
            key: ValueKey(gifUrl),
            imageUrl: gifUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Theme.of(context).cardColor),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }
}


class _ThemeToggle extends StatelessWidget {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            l10n.appearanceSettings,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor),
          ),
        ),
        ListTile(
          title: Text(l10n.darkMode, style: TextStyle(color: primaryTextColor)),
          trailing: Switch(
            value: isDark,
            onChanged: isSystem
                ? null
                : (val) {
              themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          subtitle: isSystem
              ? Text(l10n.customThemeDisabled,
              style: TextStyle(color: secondaryTextColor))
              : null,
          enabled: !isSystem,
        ),
        SwitchListTile(
          title: Text(l10n.useSystemSettings,
              style: TextStyle(color: primaryTextColor)),
          value: isSystem,
          onChanged: (useSystem) {
            themeProvider.setThemeMode(useSystem
                ? ThemeMode.system
                : (isDark ? ThemeMode.dark : ThemeMode.light));
          },
          subtitle: Text(
              isSystem
                  ? l10n.systemAutoSync
                  : l10n.systemSettingDisabled,
              style: TextStyle(color: secondaryTextColor)),
        ),
      ],
    );
  }
}
