// lib/screens/main_screen_wrapper.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:provider/provider.dart';

// Tema ve Renkler
import '../../theme/app_theme.dart'; 

// Tüm ana sayfaları içe aktar
import 'profile_screen.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'gif_upload_screen.dart'; 

// 'Öğren' sekmesi artık "Oluşturduklarım" ve "Kaydettiklerim"i gösterecek.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Kullanıcı giriş yapmamışsa veya veri yükleniyorsa bilgi ver
        if (profileProvider.userData == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.learn)),
            body: Center(child: Text(l10n.pleaseLoginToSeeProfile)),
          );
        }

        final createdGifs = profileProvider.createdGifs;
        final savedGifs = profileProvider.savedGifs;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            // AppBar'ı kaldırıyoruz ve içeriği SafeArea ile sarmalıyoruz.
            body: SafeArea(
              child: Column(
              children: [
                TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).hintColor,
                  tabs: [
                    Tab(text: l10n.created, icon: const Icon(Icons.grid_on)),
                    Tab(text: l10n.saved, icon: const Icon(Icons.bookmark)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _GifGrid(
                        key: ValueKey('created_gifs_${createdGifs.length}'),
                        gifs: createdGifs,
                        noContentMessage: l10n.noGifsCreatedYet,
                      ),
                      _GifGrid(
                        key: ValueKey('saved_gifs_${savedGifs.length}'),
                        gifs: savedGifs,
                        noContentMessage: l10n.noGifsSavedYet,
                      ),
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

// ProfileScreen'den buraya taşınan GIF grid widget'ı
class _GifGrid extends StatelessWidget {
  final List<Map<String, dynamic>> gifs;
  final String noContentMessage;
  const _GifGrid({super.key, required this.gifs, required this.noContentMessage});

  @override
  Widget build(BuildContext context) {
    if (gifs.isEmpty) {
      return Center(child: Text(noContentMessage));
    }
    return GridView.builder(
      key: key,
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

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
 int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const GifUploadScreen(),
    const LearnScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Yerelleştirme verilerini almak için l10n nesnesini alıyoruz.
    final l10n = AppLocalizations.of(context)!;

    // Mevcut temadan renkleri alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Navigasyon Çubuğu Arka Plan Rengi: Temaya Duyarlı
    final navBarBackgroundColor = isDark 
      ? const Color(0xFF1B0C27) // Koyu tema için koyu mor/siyah tonu
      : AppColors.cardColorLight; // Açık tema için kart rengi (Beyaz/Açık Gri)
      
    // İkon Renkleri: Temaya Duyarlı
    final selectedColor = theme.colorScheme.primary; // Mor vurgu
    final unselectedColor = theme.hintColor.withOpacity(0.7); // Temaya duyarlı gri

    return Scaffold(
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        // TEMA DUYARLI ARKA PLAN
        backgroundColor: navBarBackgroundColor, 
        
        // TEMA DUYARLI ÖĞE RENKLERİ
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        
        type: BottomNavigationBarType.fixed,

        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: l10n.discover),
          BottomNavigationBarItem(icon: const Icon(Icons.add_circle_outline), label: l10n.create),
          BottomNavigationBarItem(icon: const Icon(Icons.save_rounded), label: l10n.gallery),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
        ],
        
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}