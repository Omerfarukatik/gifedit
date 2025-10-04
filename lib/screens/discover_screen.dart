import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/services/download_service.dart'; // İndirme servisini import et
import 'package:memecreat/services/meme_post_card.dart';
import 'package:memecreat/theme/app_theme.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {

  // Hangi GIF'in indirildiğini takip etmek için state değişkeni
  String? _downloadingGifId;

  final DownloadService _downloadService = DownloadService(); // Servis'ten bir nesne oluştur

  @override
  bool get wantKeepAlive => true; // ← SCROLL POZİSYONUNU KORUR

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.contentColor : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ← BU SATIRLA BAŞLAMALI

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(context, l10n.all, isSelected: true),
                  _buildFilterChip(context, l10n.popular),
                  _buildFilterChip(context, l10n.newest),
                  _buildFilterChip(context, l10n.trending),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('gifs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(l10n.gifNotFound));
                }

                final gifDocs = snapshot.data!.docs;

                return ListView.builder(
                  key: const PageStorageKey<String>('discover_list'), // ← SCROLL POZİSYONU KAYDET
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  itemCount: gifDocs.length,
                  itemBuilder: (context, index) {
                    final gifData = gifDocs[index].data();
                    final gifId = gifData['id'] as String? ?? '';
                    if (gifId.isEmpty) return const SizedBox.shrink();

                    final List<dynamic> likedByList = gifData['likedBy'] ?? [];
                    final likeCount = likedByList.length;
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                    final isLiked = (currentUserId != null)
                        ? likedByList.contains(currentUserId)
                        : false;
                    final imageUrl = gifData['gifUrl'] as String? ?? '';

                    // ← CONSUMER'I BURAYA TAŞI, SADECE BU CARD İÇİN
                    return Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: MemePostCard(
                            key: ValueKey(gifId),
                            gifData: gifData,
                            likeCount: likeCount,
                            isLiked: isLiked,
                            isSaved: profileProvider.isGifSaved(gifId),
                            isProcessingLike: profileProvider.isProcessingLike(gifId),
                            isProcessingSave: profileProvider.isProcessingSave(gifId),
                            onLikePressed: () => profileProviderForActions.toggleLikeGif(gifId),
                            onSavePressed: () => profileProviderForActions.toggleSaveGif(gifData),
                            // --- YENİ: Sadece indirme butonu görünsün ---
                            showLikeButton: false,
                            showSaveButton: false,
                            // --- YENİ: Tıklayınca resmi büyüt ---
                            openInDialogOnClick: true,
                            isDownloading: _downloadingGifId == gifId, // Bu kartın indirilip indirilmediğini kontrol et
                            onDownloadPressed: () async {
                              if (imageUrl.isNotEmpty && _downloadingGifId == null) {
                                setState(() => _downloadingGifId = gifId); // İndirmeyi başlat
                                try {
                                  await _downloadService.saveGifToGallery(context, imageUrl);
                                } finally {
                                  // İşlem bitince (hata olsa bile) spinner'ı kaldır
                                  if (mounted) {
                                    setState(() => _downloadingGifId = null);
                                  }
                                }
                              }
                            },
                          ),
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