import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class MemePostCard extends StatelessWidget {
  final String? username;
  final String? userAvatarUrl;
  final String? caption;
  final int likeCount;
  final String imageUrl;
  final bool isAsset;
  final Map<String, dynamic> gifData;

  const MemePostCard({
    super.key,
    this.username,
    this.userAvatarUrl,
    this.caption,
    required this.likeCount,
    required this.imageUrl,
    this.isAsset = false,
    required this.gifData,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder bize üst widget'ın (ekranın) kısıtlamalarını verir.
    return LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final cardColor = theme.cardColor;
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

        final displayUsername = username ?? l10n.username;
        final displayCaption = caption ?? '';

        return Container(
          // Genişliği, LayoutBuilder'dan gelen maksimum genişlik olarak ayarlıyoruz.
          // Bu, taşmayı imkansız kılar.
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Column'un çocuklarının taşmasını engellemek için.
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Gönderi Başlığı
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (userAvatarUrl != null && userAvatarUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(userAvatarUrl!)
                        : null,
                    child: (userAvatarUrl == null || userAvatarUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayUsername,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        // Sabit metni l10n'dan alıyoruz.
                        Text("posted2hAgo", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Resim/GIF Alanı
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: isAsset
                    ? Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity)
                    : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: theme.hoverColor,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: theme.hoverColor,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Etkileşim Butonları (SORUNUN KAYNAĞI)
              // Bu Row'u tekrar, Spacer ile düzgün bir şekilde kuruyoruz.
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.favorite_border), iconSize: 28, onPressed: () {}),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.mode_comment_outlined), iconSize: 28, onPressed: () {}),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.send_outlined), iconSize: 28, onPressed: () {}),
                  const Spacer(), // Aradaki tüm boşluğu doldurur.
                  Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      final bool isSaved = provider.isGifSaved(gifData['id']);
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? theme.colorScheme.primary : null,
                        ),
                        iconSize: 28,
                        onPressed: () {
                          profileProvider.toggleSaveGif(gifData);
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Beğeni Sayısı
              if (likeCount > 0) ...[
                Text('$likeCount ${l10n.likes}'),
                const SizedBox(height: 12),
              ],

              // Caption (Açıklama)
              if (displayCaption.isNotEmpty)
                Text(displayCaption),
            ],
          ),
        );
      },
    );
  }
}
