// lib/services/meme_post_card.dart (YENİDEN TASARLANMIŞ, ŞIK VERSİYON)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/screens/gif_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago; // ZAMAN FORMATI İÇİN EKLENDİ

// Beğeni sayısını formatlayan yardımcı fonksiyon (Aynı kalıyor)
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
  final VoidCallback onDownloadPressed;
  final bool isDownloading; // İndirme durumunu takip etmek için yeni parametre

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
    required this.onDownloadPressed,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Verileri Map'ten güvenli bir şekilde alalım
    final username = gifData['creatorUsername'] ?? l10n.username;
    final userAvatarUrl = gifData['creatorProfileUrl'] as String?;
    final caption = gifData['caption'] as String? ?? '';
    final imageUrl = gifData['gifUrl'] as String? ?? '';
    final postTimestamp = gifData['createdAt'] as Timestamp?;
    final postDate = postTimestamp?.toDate();
    // Zaman formatını dinamik hale getiriyoruz. (Örn: 5 dakika önce)
    final timeAgoString = postDate != null ? timeago.format(postDate, locale: Localizations.localeOf(context).languageCode) : '';


    return Container(
      // ESTETİK DEVRİM 1: Kartın etrafına zarif bir gölge eklendi.
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Bütün içeriği, taşmaları önlemek ve köşeleri yuvarlatmak için ClipRRect içine alıyoruz.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tıklanabilir kullanıcı başlığı
            GestureDetector(
              onTap: () {
                // TODO: Kullanıcının profiline gitme fonksiyonu
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                      backgroundImage: (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(userAvatarUrl)
                          : null,
                      child: (userAvatarUrl == null || userAvatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (timeAgoString.isNotEmpty)
                            Text(timeAgoString, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    // "More" butonu biraz daha az yer kaplayabilir.
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () { /* Diğer seçenekler menüsü */ },
                        icon: const Icon(Icons.more_horiz)
                    ),
                  ],
                ),
              ),
            ),

            // ESTETİK DEVRİM 2: GIF'e tıklandığında detay sayfasına gitmesi için GestureDetector.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GifDetailPage(
                      gifUrl: imageUrl,
                      userName: username,
                      userProfileImageUrl: userAvatarUrl ?? '',
                      description: caption,
                      postDate: postDate?.toString().substring(0, 10) ?? l10n.unknownDate,
                      likeCount: likeCount,
                      isLiked: isLiked,
                    ),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  ),
                ),
                errorWidget: (context, url, error) => AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),

            // ESTETİK DEVRİM 3: Butonların ve yazıların olduğu daha temiz bir alt bölüm.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Beğeni butonu ve sayısı bir arada, daha kompakt.
                      _buildActionButton(
                        context,
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        label: _formatLikes(likeCount),
                        color: isLiked ? Colors.redAccent : theme.iconTheme.color,
                        onPressed: isProcessingLike ? null : onLikePressed,
                      ),
                      const SizedBox(width: 16),
                      // BUTON REVİZYONU: YENİ İNDİRME BUTONU
                      // İndirme durumuna göre ya butonu ya da spinner'ı göster
                      isDownloading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0), // Butonla aynı hizada olması için
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            )
                          : _buildActionButton(
                              context,
                              icon: Icons.download_outlined,
                              label: l10n.download,
                              onPressed: onDownloadPressed,
                            ),
                      const Spacer(),
                      // Kaydetme butonu
                      _buildActionButton(
                        context,
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? theme.colorScheme.primary : theme.iconTheme.color,
                        onPressed: isProcessingSave ? null : onSavePressed,
                      ),
                    ],
                  ),

                  // Açıklama alanı sadece caption varsa gösterilir.
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                              text: '$username ',
                              style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(text: caption),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ESTETİK DEVRİM 4: Butonları ve yazılarını bir araya getiren yardımcı bir widget.
  // Bu, kod tekrarını azaltır ve daha temiz bir yapı sağlar.
  Widget _buildActionButton(BuildContext context, {required IconData icon, String? label, Color? color, VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: onPressed == null ? Colors.grey : color, size: 24),
            if (label != null && label.isNotEmpty) ...[
              const SizedBox(width: 8.0),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onPressed == null ? Colors.grey : theme.textTheme.bodyMedium?.color
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
