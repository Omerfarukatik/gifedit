import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/gif_provider.dart'; // <<< YENİ VE EN ÖNEMLİ İMPORT
import 'package:memecreat/services/meme_post_card.dart';
import 'package:memecreat/theme/app_theme.dart';
import 'package:provider/provider.dart'; // <<< PROVIDER İÇİN İMPORT

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
            label,
            style: TextStyle(
                color: isSelected ? AppColors.contentColor : theme.colorScheme.primary
            )
        ),
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
        side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.hintColor.withOpacity(isDark ? 0.5 : 0.2)
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final secondaryTextColor = theme.hintColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover),
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchMemes,
                hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),

          // Filtreleme Etiketleri
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, l10n.all, isSelected: true),
                  _buildFilterChip(context, 'A1'),
                  _buildFilterChip(context, 'A2'),
                  _buildFilterChip(context, 'B1'),
                  _buildFilterChip(context, 'B2'),
                  _buildFilterChip(context, 'C1'),
                ],
              ),
            ),
          ),

          // #################### ASIL DEĞİŞİKLİK BURADA ####################
          // Meme Akışı
          Expanded(
            // `Consumer` ile `GifProvider`'ı dinliyoruz.
            child: Consumer<GifProvider>(
              builder: (context, gifProvider, child) {
                // Yüklenme durumu
                if (gifProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumu
                if (gifProvider.error != null) {
                  return Center(child: Text(gifProvider.error!));
                }
                // Boş liste durumu
                if (gifProvider.gifs.isEmpty) {
                  return Center(child: Text(l10n.gifNotFound));
                }

                // Gerçek veriyle çalışan ListView
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  itemCount: gifProvider.gifs.length,
                  itemBuilder: (context, index) {
                    final gifData = gifProvider.gifs[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      // Güncellenmiş MemePostCard'ı DOĞRU parametrelerle çağırıyoruz.
                      child: MemePostCard(
                        username: gifData['creatorUsername'] ?? l10n.username,
                        userAvatarUrl: gifData['creatorProfileUrl'],
                        caption: "Harika bir GIF!", // TODO: Açıklama eklenecek
                        likeCount: gifData['likes'] ?? 0,
                        // 'imagePath' YERİNE 'imageUrl' KULLANIYORUZ
                        imageUrl: gifData['gifUrl'],
                        isAsset: false, // Network'ten yüklendiğini belirtiyoruz
                        gifData: gifData
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // #################################################################
        ],
      ),
    );
  }
}
