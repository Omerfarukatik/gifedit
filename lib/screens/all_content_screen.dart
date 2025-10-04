import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // debugPrint için eklendi
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
    
    debugPrint("[AllContentScreen] Build metodu çalıştı. İçerik Tipi: ${widget.contentType}");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentType),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          debugPrint("[AllContentScreen] Consumer build. Yükleniyor: ${profileProvider.isLoading}, "
                     "Kaydedilenler: ${profileProvider.savedGifs.length}, "
                     "Oluşturulanlar: ${profileProvider.createdGifs.length}");

          // Başlangıç verisini ve ID'leri almak için provider'ı kullanıyoruz.
          final List<Map<String, dynamic>> initialItems =
              (widget.contentType == l10n.savedMemes)
                  ? profileProvider.savedGifs
                  : profileProvider.createdGifs;

          if (profileProvider.isLoading) {
            debugPrint("[AllContentScreen] ProfileProvider yükleniyor, bekleme ekranı gösteriliyor.");
            return const Center(child: CircularProgressIndicator());
          }
          if (initialItems.isEmpty) {
            debugPrint("[AllContentScreen] Gösterilecek öğe yok ('${widget.contentType}').");
            return Center(child: Text(l10n.nothingHereYet));
          }

          // Gösterilecek GIF'lerin ID listesini oluşturuyoruz.
          final List<String> gifIds =
              initialItems.map((item) => item['id'] as String).toList();

          debugPrint("[AllContentScreen] StreamBuilder için sorgulanan GIF ID'leri: $gifIds");
          // Bu ID'leri kullanarak `gifs` koleksiyonundan CANLI bir stream çekiyoruz.
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // `whereIn` sorgusu ile sadece bu ekranda olması gereken GIF'leri çekiyoruz.
            stream: FirebaseFirestore.instance
                .collection('gifs')
                .where('id', whereIn: gifIds.isNotEmpty ? gifIds : ['placeholder'])
                .snapshots(),
            builder: (context, snapshot) {
              // --- HATA KONTROLÜ ---
              if (snapshot.hasError) {
                debugPrint("[AllContentScreen] StreamBuilder HATA: ${snapshot.error}");
                return Center(child: Text("Veri yüklenirken bir hata oluştu: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                debugPrint("[AllContentScreen] StreamBuilder veri bekliyor...");
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // Stream'den veri gelmiyorsa veya boşsa, başlangıç listesine göre
                // bir "Hiçbir şey yok" mesajı göster.
                debugPrint("[AllContentScreen] Stream'den veri gelmedi veya gelen veri boş.");
                return Center(child: Text(l10n.nothingHereYet));
              }

              // Gelen canlı dökümanları, ProfileProvider'daki orijinal sıraya göre diziyoruz.
              final liveDocs = snapshot.data!.docs;
              final sortedDocs =
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(liveDocs)
                    ..sort((a, b) =>
                        gifIds.indexOf(a.id).compareTo(gifIds.indexOf(b.id)));
              
              debugPrint("[AllContentScreen] ${sortedDocs.length} adet canlı döküman bulundu ve sıralandı.");

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  // ARTIK DONMUŞ `items` LİSTESİ YERİNE, CANLI `sortedDocs` KULLANIYORUZ.
                  final gifData = sortedDocs[index].data();
                  final gifId = gifData['id'] as String? ?? '';
                  final imageUrl = gifData['gifUrl'] as String? ?? '';
                  if (gifId.isEmpty) {
                    debugPrint("[AllContentScreen] UYARI: ID'si olmayan bir GIF dökümanı atlandı.");
                    return const SizedBox.shrink();
                  }

                  return Padding( // Kartlar arası dikey boşluk
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: MemePostCard(
                      key: ValueKey(gifId),
                      gifData: gifData,
                      isSaved: profileProvider.isGifSaved(gifId),
                      isProcessingSave: profileProvider.isProcessingSave(gifId),
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
