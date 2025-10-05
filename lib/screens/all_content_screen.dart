// lib/screens/all_content_screen.dart (MİMARİSİ DÜZELTİLMİŞ, 30 LİMİTİ HATASI ÇÖZÜLMÜŞ, NİHAİ VERSİYON)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/services/download_service.dart';
import 'package:memecreat/services/meme_post_card.dart';
import 'package:provider/provider.dart';

// === LİSTEYİ 30'LUK PARÇALARA AYIRAN YARDIMCI FONKSİYON (BU DOĞRUYDU) ===
extension Chunk<T> on List<T> {
  List<List<T>> chunk(int chunkSize) {
    List<List<T>> chunks = [];
    if (isEmpty) return chunks;
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }
}
// =======================================================================

class AllContentScreen extends StatefulWidget {
  final String contentType;
  const AllContentScreen({super.key, required this.contentType});

  @override
  State<AllContentScreen> createState() => _AllContentScreenState();
}

class _AllContentScreenState extends State<AllContentScreen> {
  final DownloadService _downloadService = DownloadService();
  String? _downloadingGifId;

  // === MİMARİSİ DÜZELTİLMİŞ, PARÇALI SORGULAMA FONKSİYONU ===
  // Bu fonksiyon artık Provider'dan değil, direkt ID listesinden çalışıyor.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchGifsInChunks(
      List<String> gifIds) async {
    if (gifIds.isEmpty) {
      return []; // Çekilecek ID yoksa boş liste döndür.
    }

    // ID listesini 30'arlı parçalara ayırıyoruz.
    final chunks = gifIds.chunk(30);
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];

    for (final idChunk in chunks) {
      if (idChunk.isNotEmpty) {
        final query = FirebaseFirestore.instance
            .collection('gifs')
            .where('id', whereIn: idChunk);
        futures.add(query.get());
      }
    }

    if (futures.isEmpty) {
      return [];
    }

    final snapshots = await Future.wait(futures);

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];
    for (final snapshot in snapshots) {
      allDocs.addAll(snapshot.docs);
    }

    // Sonuçları, Provider'daki orijinal sıraya göre yeniden diziyoruz.
    allDocs.sort((a, b) => gifIds.indexOf(a.id).compareTo(gifIds.indexOf(b.id)));
    return allDocs;
  }
  // =================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // `listen: false` olan Provider'ı eylem butonları için build'in en üstünde alabiliriz.
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentType),
      ),
      // MİMARİNİN KALBİ: Consumer ile başlayıp, FutureBuilder ile devam ediyoruz.
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // 1. ADIM: Provider'dan CANLI ID listesini al.
          final List<Map<String, dynamic>> initialItems =
          (widget.contentType == l10n.savedMemes)
              ? profileProvider.savedGifs
              : profileProvider.createdGifs;

          final List<String> gifIds =
          initialItems.map((item) => item['id'] as String).toList();

          if (gifIds.isEmpty) {
            return Center(child: Text(l10n.nothingHereYet));
          }

          // 2. ADIM: Bu ID listesiyle `FutureBuilder`'ı çalıştır.
          // `FutureBuilder`'a key olarak ID'lerin birleşimini veriyoruz ki,
          // ID listesi değiştiğinde `FutureBuilder` yeniden tetiklensin.
          return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            key: ValueKey(gifIds.join(',')),
            future: _fetchGifsInChunks(gifIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Veri yüklenirken bir hata oluştu: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(l10n.nothingHereYet));
              }

              final sortedDocs = snapshot.data!;

              // 3. ADIM: Sonuçları ListView ile göster.
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  final gifData = sortedDocs[index].data();
                  final gifId = gifData['id'] as String? ?? '';
                  final imageUrl = gifData['gifUrl'] as String? ?? '';
                  if (gifId.isEmpty) return const SizedBox.shrink();

                  // Buton durumları (isSaved, isDownloading) hala Provider'dan canlı olarak dinleniyor.
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: MemePostCard(
                      key: ValueKey(gifId),
                      gifData: gifData,
                      isSaved: profileProvider.isGifSaved(gifId),
                      isProcessingSave: profileProvider.isProcessingSave(gifId),
                      onSavePressed: () => profileProviderForActions.toggleSaveGif(gifData),
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
