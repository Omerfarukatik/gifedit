// // lib/screens/profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:memecreat/screens/subscriptions_screen.dart';
// import 'package:provider/provider.dart';

// // Tema ve Navigasyon Importları
// import '../../theme/app_theme.dart';
// import '../provider/theme_provider.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   // İstatistik Sütunu
//   Widget _buildStatColumn(BuildContext context, String label, int value) {
//   final theme = Theme.of(context);
//   final secondaryTextColor = theme.hintColor;
  
//   return Column(
//     children: [
//     Text(
//       value.toString(),
//       style: TextStyle(
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//       color: theme.colorScheme.primary, // Mor vurgu
//       ),
//     ),
//     Text(
//       label,
//       style: TextStyle(
//       fontSize: 14,
//       color: secondaryTextColor, 
//       ),
//     ),
//     ],
//   );
//   }

//   // Sekmeli Menü (TabBar)
//   Widget _buildTabBar(BuildContext context) {
//   final theme = Theme.of(context);

//   return TabBar(
//     indicatorColor: theme.colorScheme.primary, 
//     labelColor: theme.colorScheme.primary,
//     unselectedLabelColor: theme.hintColor,
//     tabs: const [
//     Tab(text: 'Oluşturduklarım', icon: Icon(Icons.grid_on)),
//     Tab(text: 'Kaydettiklerim', icon: Icon(Icons.bookmark)),
//     ],
//   );
//   }

//   // İçerik Izgarası (Grid View)
//   Widget _buildUserContentGrid(BuildContext context, String type) {
//   final theme = Theme.of(context);
//   final primaryTextColor = theme.textTheme.bodyMedium!.color;

//   return GridView.builder(
//     padding: const EdgeInsets.all(4),
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//     crossAxisCount: 3,
//     crossAxisSpacing: 4.0,
//     mainAxisSpacing: 4.0,
//     ),
//     itemCount: 20,
//     itemBuilder: (context, index) {
//     return Container(
//       decoration: BoxDecoration(
//       color: theme.cardColor, 
//       borderRadius: BorderRadius.circular(4),
//       border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
//       ),
//       child: Center(
//       child: Text(
//         type,
//         style: TextStyle(color: primaryTextColor),
//       ),
//       ),
//     );
//     },
//   );
//   }

//   // TEMAYI DEĞİŞTİRME WIDGET'I
//   Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
//   final theme = Theme.of(context);
//   final currentMode = themeProvider.themeMode;
//   final isSystem = currentMode == ThemeMode.system;
//   final isDark = currentMode == ThemeMode.dark;
  
//   final primaryTextColor = theme.textTheme.bodyMedium!.color;
//   final secondaryTextColor = theme.hintColor;

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     Padding(
//       padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//       child: Text(
//         'Görünüm Ayarları',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: primaryTextColor,
//         ),
//       ),
//     ),

//     // 1. Koyu Tema (Dark Mode) Anahtarı
//     ListTile(
//       title: Text('Koyu Tema (Dark Mode)', style: TextStyle(color: primaryTextColor)),
//       trailing: Switch(
//         value: isDark,
//         onChanged: isSystem 
//           ? null 
//           : (val) {
//             themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
//           },
//       ),
//       subtitle: isSystem ? Text('Özel tema devre dışı', style: TextStyle(color: secondaryTextColor)) : null,
//       enabled: !isSystem, 
//     ),

//     // 2. Sistem Ayarını Kullan Anahtarı
//     SwitchListTile(
//       title: Text('Sistem Ayarını Kullan', style: TextStyle(color: primaryTextColor)),
//       value: isSystem,
//       onChanged: (useSystem) {
//         themeProvider.setThemeMode(useSystem ? ThemeMode.system : (isDark ? ThemeMode.dark : ThemeMode.light));
//       },
//       subtitle: Text(
//         isSystem ? 'Otomatik, cihaz ayarıyla senkronize' : 'Cihaz ayarı devre dışı', 
//         style: TextStyle(color: secondaryTextColor)
//       ),
//     ),
//     ],
//   );
//   }

//   // Profil Başlık Bölümü
//   Widget _buildProfileHeader(BuildContext context) {
//   final theme = Theme.of(context);

//   return Padding(
//     padding: const EdgeInsets.all(20.0),
//     child: Column(
//     children: [
//       // Avatar
//       CircleAvatar(
//       radius: 40,
//       backgroundColor: AppColors.primary.withOpacity(0.5),
//       // İkon rengi temadan gelecek
//       child: Icon(Icons.person, size: 50, color: theme.iconTheme.color), 
//       ),
//       const SizedBox(height: 10),

//       // Kullanıcı Adı
//       Text(
//       'senin_kullanici_adin',
//       style: theme.textTheme.titleLarge!.copyWith(
//          fontWeight: FontWeight.bold, 
//          color: theme.textTheme.bodyMedium!.color // Temaya duyarlı
//       ),
//       ),
//       const SizedBox(height: 15),

//       // İstatistikler
//       Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildStatColumn(context, 'GIF', 42),
//         _buildStatColumn(context, 'Beğeni', 1240),
//         _buildStatColumn(context, 'Takipçi', 150),
//       ],
//       ),
//     ],
//     ),
//   );
//   }

//   @override
//   Widget build(BuildContext context) {
//   // Tema sağlayıcısını dinle
//   final themeProvider = Provider.of<ThemeProvider>(context);

//   return DefaultTabController(
//     length: 2, 
//     child: Scaffold(
//     appBar: AppBar(
//       title: const Text('Profilim'),
//       elevation: 0,
//       centerTitle: true,
//       actions: [
//       IconButton(
//         icon: const Icon(Icons.settings), 
//         onPressed: () {
//         // Abonelikler sayfasına geçiş
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const SubscriptionsScreen()),
//         );
//         },
//       ),
//       ],
//     ),
//     body: Column(
//       children: [
//       // 1. Üst Bölüm: Avatar ve İstatistikler
//       _buildProfileHeader(context),

//       // 2. TEMA AYARLARI
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//         child: _buildThemeToggle(context, themeProvider),
//       ),
//       const Divider(height: 1),
      
//       // 3. TabBar (Sekmeli Menü)
//       _buildTabBar(context),

//       // 4. İçerik Akışı (Sekme İçeriği)
//       Expanded(
//         child: TabBarView(
//         children: [
//           _buildUserContentGrid(context, 'Oluşturulan'),
//           _buildUserContentGrid(context, 'Kaydedilen'),
//         ],
//         ),
//       ),
//       ],
//     ),
//     ),
//   );
//   }
// }

// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/theme_provider.dart';
import 'package:memecreat/screens/subscriptions_screen.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // İstatistik Sütunu (TEMA DUYARLI)
  Widget _buildStatColumn(BuildContext context, String label, int value) {
    final theme = Theme.of(context);
    final secondaryTextColor = theme.hintColor;
    
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary, // Mor vurgu
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor, 
          ),
        ),
      ],
    );
  }

  // Sekmeli Menü (TabBar) (TEMA DUYARLI ve YERELLEŞTİRİLDİ)
  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return TabBar(
      indicatorColor: theme.colorScheme.primary, 
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.hintColor,
      tabs: [
        Tab(text: l10n.created, icon: const Icon(Icons.grid_on)), // YERELLEŞTİRİLDİ
        Tab(text: l10n.saved, icon: const Icon(Icons.bookmark)), // YERELLEŞTİRİLDİ
      ],
    );
  }

  // İçerik Izgarası (Grid View) (TEMA DUYARLI)
  Widget _buildUserContentGrid(BuildContext context, String type) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor, 
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(color: primaryTextColor), 
            ),
          ),
        );
      },
    );
  }

  // TEMAYI DEĞİŞTİRME WIDGET'I (YERELLEŞTİRİLDİ)
  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
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
                l10n.appearanceSettings, // YERELLEŞTİRİLDİ
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                ),
            ),
        ),

        // 1. Koyu Tema (Dark Mode) Anahtarı
        ListTile(
            title: Text(l10n.darkMode, style: TextStyle(color: primaryTextColor)), // YERELLEŞTİRİLDİ
            trailing: Switch(
                value: isDark,
                onChanged: isSystem ? null : (val) {
                    themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
            ),
            subtitle: isSystem ? Text(l10n.customThemeDisabled, style: TextStyle(color: secondaryTextColor)) : null, // YERELLEŞTİRİLDİ
            enabled: !isSystem, 
        ),

        // 2. Sistem Ayarını Kullan Anahtarı
        SwitchListTile(
            title: Text(l10n.useSystemSettings, style: TextStyle(color: primaryTextColor)), // YERELLEŞTİRİLDİ
            value: isSystem,
            onChanged: (useSystem) {
                themeProvider.setThemeMode(useSystem ? ThemeMode.system : (isDark ? ThemeMode.dark : ThemeMode.light));
            },
            subtitle: Text(
                isSystem ? l10n.systemAutoSync : l10n.systemSettingDisabled, // YERELLEŞTİRİLDİ
                style: TextStyle(color: secondaryTextColor)
            ),
        ),
      ],
    );
  }

  // Profil Başlık Bölümü
  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!; // l10n eklendi

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.5),
            child: Icon(Icons.person, size: 50, color: theme.iconTheme.color), 
          ),
          const SizedBox(height: 10),

          // Kullanıcı Adı
          Text(
            l10n.username, // YERELLEŞTİRİLDİ (senin_kullanici_adin yerine)
            style: theme.textTheme.titleLarge!.copyWith(
                 fontWeight: FontWeight.bold, 
                 color: theme.textTheme.bodyMedium!.color
            ),
          ),
          const SizedBox(height: 15),

          // İstatistikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(context, l10n.gifStat, 42), // YERELLEŞTİRİLDİ
              _buildStatColumn(context, l10n.likeStat, 1240), // YERELLEŞTİRİLDİ
              _buildStatColumn(context, l10n.followerStat, 150), // YERELLEŞTİRİLDİ
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profile), // YERELLEŞTİRİLDİ
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings), 
              onPressed: () {
                // Abonelikler sayfasına geçiş
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  SubscriptionsScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // 1. Üst Bölüm: Avatar ve İstatistikler
            _buildProfileHeader(context),

            // 2. TEMA AYARLARI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: _buildThemeToggle(context, themeProvider, l10n),
            ),
            const Divider(height: 1),
            
            // 3. TabBar (Sekmeli Menü)
            _buildTabBar(context, l10n), // l10n argümanı eklendi

            // 4. İçerik Akışı (Sekme İçeriği)
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserContentGrid(context, l10n.created), // YERELLEŞTİRİLDİ
                  _buildUserContentGrid(context, l10n.saved), // YERELLEŞTİRİLDİ
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}