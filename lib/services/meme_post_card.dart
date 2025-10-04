// lib/services/meme_post_card.dart (YENİDEN TASARLANMIŞ, ŞIK VERSİYON)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/screens/gif_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago; // ZAMAN FORMATI İÇİN EKLENDİ

// BU WIDGET PROVIDER'I BİLMEZ. SADECE VERİ ALIR VE FONKSİYON TETİKLER.
class MemePostCard extends StatelessWidget {
  final Map<String, dynamic> gifData;
  final bool isSaved;
  final bool isProcessingSave;
  final VoidCallback onSavePressed;
  final VoidCallback onDownloadPressed;
  final bool isDownloading; // İndirme durumunu takip etmek için yeni parametre

  const MemePostCard({
    super.key,
    required this.gifData,
    required this.isSaved,
    required this.isProcessingSave,
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
      // DEĞİŞİKLİK: Gölge kaldırıldı ve margin ayarlandı.
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
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
                    // DEĞİŞİKLİK: Kaydet butonu buradan kaldırıldı, yerine "Daha Fazla" menüsü geldi.
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () { /* Diğer seçenekler menüsü */ },
                      icon: const Icon(Icons.more_horiz),
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
                      gifData: gifData, // <<< YENİ: Tüm veriyi detay sayfasına gönderiyoruz.
                      gifUrl: imageUrl,
                      userName: username,
                      userProfileImageUrl: userAvatarUrl ?? '',
                      description: caption,
                      postDate: timeAgoString, // Detay sayfasında da "5 dakika önce" gibi görünsün.
                    ),
                  ),
                );
              },
              // DEĞİŞİKLİK: GIF'lerin farklı boyutlarda olmasını engellemek için AspectRatio kullanıyoruz.
              child: AspectRatio(
                aspectRatio: 4 / 3, // Tüm kartların aynı oranda olmasını sağlar.
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover, // Görüntünün alanı doldurmasını sağlar.
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                    ),
                  errorWidget: (context, url, error) => Container(
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
                      // DEĞİŞİKLİK: Kaydetme butonu tekrar buraya eklendi.
                      _buildActionButton(
                        context,
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? theme.colorScheme.primary : theme.iconTheme.color,
                        onPressed: isProcessingSave ? null : onSavePressed,
                        // Butonun etrafındaki tıklama alanını genişletmek için label'sız versiyon
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
