// lib/services/meme_post_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tarih formatı için eklendi
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/screens/gif_detail_page.dart'; // Detay sayfasına yönlendirme için eklendi

// Beğeni sayısını formatlayan yardımcı fonksiyon
String _formatLikes(int count) {
  if (count < 0) return '0';
  if (count < 1000) return count.toString();
  if (count < 1000000) return '${(count / 1000.0).toStringAsFixed(1)}K';
  return '${(count / 1000000.0).toStringAsFixed(1)}M';
}

// BU WIDGET PROVIDER'I BİLMEZ. SADECE VERİ ALIR VE FONKSİYON TETİKLER.
class MemePostCard extends StatelessWidget {
  final Map<String, dynamic> gifData;
  final int likeCount;
  final bool isLiked;
  final bool isSaved;
  final bool isProcessingLike;
  final bool isProcessingSave;
  final VoidCallback onLikePressed;
  final VoidCallback onSavePressed;

  const MemePostCard({
    super.key,
    required this.gifData,
    required this.likeCount,
    required this.isLiked,
    required this.isSaved,
    required this.isProcessingLike,
    required this.isProcessingSave,
    required this.onLikePressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Verileri Map'ten güvenli bir şekilde alalım
    final username = gifData['creatorUsername'] ?? l10n.username;
    final userAvatarUrl = gifData['creatorProfileUrl'] as String?;
    final caption = gifData['caption'] as String? ?? '';
    final imageUrl = gifData['gifUrl'] as String? ?? '';
    final postTimestamp = gifData['createdAt'] as Timestamp?;

    // --- YÖNLENDİRME İÇİN DEĞİŞİKLİK ---
    // En dıştaki Container, GestureDetector ile sarıldı.
    return GestureDetector(
      onTap: () {
        // Tıklandığında GifDetailPage'i aç
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GifDetailPage(
              gifUrl: imageUrl,
              userName: username,
              userProfileImageUrl: userAvatarUrl ?? '',
              description: caption,
              postDate: postTimestamp?.toDate().toString().substring(0, 10) ?? 'Bilinmeyen tarih',
              likeCount: likeCount,
              isLiked: isLiked,
            ),
          ),
        );
      },
      // Opak bir davranış belirleyerek GestureDetector'ın boş alanlarda da tıklamayı algılamasını sağlıyoruz.
      behavior: HitTestBehavior.opaque,
      // ------------------------------------
      child: Container(
        // Kartların arasında dikey boşluk bırakmak için margin eklendi.
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KULLANICI BAŞLIĞI
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(userAvatarUrl)
                      : null,
                  child: (userAvatarUrl == null || userAvatarUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // TODO: Bu '2h ago' kısmını dinamik hale getir (timeago.dart paketi ile)
                      Text("2h ago", style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      /* Diğer seçenekler menüsü (Sil, Bildir vb.) */
                    },
                    icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: 16),

            // GIF GÖRSELİ
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                // Yüklenirken ve hata durumunda kartın boyutunun değişmemesi için AspectRatio kullanıldı.
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: 1, // 1:1 kare oran
                  child: Container(
                    color: theme.hoverColor,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                errorWidget: (context, url, error) => AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: theme.hoverColor,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AKSİYON BUTONLARI
            Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : null),
                  iconSize: 28,
                  onPressed: isProcessingLike ? null : onLikePressed,
                ),
                const SizedBox(width: 8),
                IconButton(
                    icon: const Icon(Icons.mode_comment_outlined),
                    iconSize: 28,
                    onPressed: () {
                      /* Yorumlar alanını aç */
                    }),
                const SizedBox(width: 8),
                IconButton(
                    icon: const Icon(Icons.send_outlined),
                    iconSize: 28,
                    onPressed: () {
                      /* Paylaş menüsünü aç */
                    }),
                const Spacer(),
                IconButton(
                  icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? theme.colorScheme.primary : null),
                  iconSize: 28,
                  onPressed: isProcessingSave ? null : onSavePressed,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // BEĞENİ VE AÇIKLAMA
            if (likeCount > 0)
              Text(
                '${_formatLikes(likeCount)} ${l10n.likes}',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            if (caption.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                        text: '$username ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: caption),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}