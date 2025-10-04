import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/services/download_service.dart';
import 'package:memecreat/services/meme_post_card.dart';
import 'package:provider/provider.dart';

class AllContentScreen extends StatefulWidget {
  final String contentType;
  const AllContentScreen({super.key, required this.contentType});

  @override
  State<AllContentScreen> createState() => _AllContentScreenState();
}

class _AllContentScreenState extends State<AllContentScreen> {
  // DownloadService'i burada da kullanmak için bir nesne oluşturalım.
  final DownloadService _downloadService = DownloadService();
  String? _downloadingGifId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileProviderForActions =
        Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentType),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // Başlangıç verisini ve ID'leri almak için provider'ı kullanıyoruz.
          final List<Map<String, dynamic>> initialItems =
              (widget.contentType == l10n.savedMemes)
                  ? profileProvider.savedGifs
                  : profileProvider.createdGifs;

          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (initialItems.isEmpty) {
            return Center(child: Text(l10n.nothingHereYet));
          }

          // Gösterilecek GIF'lerin ID listesini oluşturuyoruz.
          final List<String> gifIds =
              initialItems.map((item) => item['id'] as String).toList();

          // Bu ID'leri kullanarak `gifs` koleksiyonundan CANLI bir stream çekiyoruz.
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // `whereIn` sorgusu ile sadece bu ekranda olması gereken GIF'leri çekiyoruz.
            stream: FirebaseFirestore.instance
                .collection('gifs')
                .where('id', whereIn: gifIds.isNotEmpty ? gifIds : ['placeholder'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // Stream'den veri gelmiyorsa veya boşsa, başlangıç listesine göre
                // bir "Hiçbir şey yok" mesajı göster.
                return Center(child: Text(l10n.nothingHereYet));
              }

              // Gelen canlı dökümanları, ProfileProvider'daki orijinal sıraya göre diziyoruz.
              final liveDocs = snapshot.data!.docs;
              final sortedDocs =
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(liveDocs)
                    ..sort((a, b) =>
                        gifIds.indexOf(a.id).compareTo(gifIds.indexOf(b.id)));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  // ARTIK DONMUŞ `items` LİSTESİ YERİNE, CANLI `sortedDocs` KULLANIYORUZ.
                  final gifData = sortedDocs[index].data();
                  final gifId = gifData['id'] as String? ?? '';
                  final imageUrl = gifData['gifUrl'] as String? ?? '';
                  if (gifId.isEmpty) return const SizedBox.shrink();

                  // Bu kısım artık doğru çalışacak çünkü `gifData` her zaman en güncel veri.
                  final List<dynamic> likedByList = gifData['likedBy'] ?? [];
                  final likeCount = likedByList.length;
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final isLiked = (currentUserId != null)
                      ? likedByList.contains(currentUserId)
                      : false;

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
                      onLikePressed: () =>
                          profileProviderForActions.toggleLikeGif(gifId),
                      onSavePressed: () =>
                          profileProviderForActions.toggleSaveGif(gifData),
                      isDownloading: _downloadingGifId == gifId,
                      onDownloadPressed: () async {
                        if (imageUrl.isNotEmpty && _downloadingGifId == null) {
                          setState(() => _downloadingGifId = gifId);
                          try {
                            await _downloadService.saveGifToGallery(context, imageUrl);
                          } finally {
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
    );
  }
}
