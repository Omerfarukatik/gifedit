import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart'; // <<< PROVIDER'I BURAYA EKLEDİK
import 'package:memecreat/services/meme_post_card.dart';
import 'package:memecreat/theme/app_theme.dart';
import 'package:provider/provider.dart'; // <<< PROVIDER'I BURAYA EKLEDİK

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    // Bu metod aynı kalıyor...
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: TextStyle(color: isSelected ? AppColors.contentColor : theme.colorScheme.primary)),
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
        side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.hintColor.withOpacity(isDark ? 0.5 : 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // `listen: false` ile provider'ı sadece fonksiyon çağırmak için alıyoruz.
    // UI güncellemeleri için Consumer kullanacağız.
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.discover),/*...*/),
      body: Column(
        children: [
          // Arama ve Filtreler aynı kalıyor...
          // ...

          Expanded(
            // Consumer ile ProfileProvider'ı (isLiked, isSaved durumları için) dinliyoruz
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                // StreamBuilder ile GIF listesini (likeCount için) dinliyoruz
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('gifs').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final gifDocs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      itemCount: gifDocs.length,
                      itemBuilder: (context, index) {
                        final gifData = gifDocs[index].data();
                        final gifId = gifData['id'] as String? ?? '';
                        if(gifId.isEmpty) return const SizedBox.shrink();

                        final List<dynamic> likedByList = gifData['likedBy'] ?? [];
                        final likeCount = likedByList.length; // << BEĞENİ SAYISI ARTIK BURADAN GELİYOR!

                        // "Ben bu GIF'i beğendim mi?" sorusunun cevabı:
                        final currentUserId = Provider.of<ProfileProvider>(context, listen: false).userData?['uid'];
                        final isLiked = (currentUserId != null) ? likedByList.contains(currentUserId) : false;

                        return MemePostCard(
                          key: ValueKey(gifId),
                          gifData: gifData,
                          likeCount: likeCount, // << YENİ, DOĞRU SAYI
                          isLiked: isLiked,     // << YENİ, DOĞRU DURUM
                          isSaved: profileProvider.isGifSaved(gifId), // Save aynı kalabilir
                          isProcessingLike: profileProvider.isProcessingLike(gifId),
                          isProcessingSave: profileProvider.isProcessingSave(gifId),
                          onLikePressed: () => profileProvider.toggleLikeGif(gifId),
                          onSavePressed: () => profileProvider.toggleSaveGif(gifData),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}