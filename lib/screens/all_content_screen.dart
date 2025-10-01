import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart'; // GERÇEK VERİ İÇİN
import 'package:memecreat/services/meme_post_card.dart';
import 'package:provider/provider.dart';

class AllContentScreen extends StatelessWidget {
  final String contentType;

  const AllContentScreen({super.key, required this.contentType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(contentType),
        elevation: 0,
        centerTitle: true,
      ),
      // Provider'ı dinleyerek listeyi dinamik hale getiriyoruz
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // Hangi listeyi göstereceğimizi contentType'a göre belirliyoruz.
          final List<Map<String, dynamic>> items;
          if (contentType == l10n.savedMemes) {
            items = profileProvider.savedGifs;
          } else if (contentType == l10n.recentCreations) {
            items = profileProvider.createdGifs;
          } else {
            items = []; // Beklenmedik bir durum için boş liste
          }

          if (items.isEmpty) {
            return Center(child: Text(l10n.nothingHereYet));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final gifData = items[index];

              // Veritabanından gelen verileri MemePostCard'a aktar
              return Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MemePostCard(
                  username: gifData['creatorUsername'] ?? l10n.username,
                  userAvatarUrl: gifData['creatorProfileUrl'],
                  caption: "Harika bir GIF!", // TODO: Buraya da dinamik bir açıklama gelebilir
                  likeCount: gifData['likes'] ?? 0,
                  imageUrl: gifData['gifUrl'], // GERÇEK GIF URL'Sİ
                  isAsset: false, // Network'ten yükleneceğini belirtiyoruz
                  gifData: gifData
                ),
              );
            },
          );
        },
      ),
    );
  }
}
