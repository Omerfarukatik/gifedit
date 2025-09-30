import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/theme/app_theme.dart';

class MemePostCard extends StatelessWidget {
  final String username;
  final String caption;
  final int likeCount;
  final String imagePath;

  const MemePostCard({
    super.key,
    required this.username,
    required this.caption,
    required this.likeCount,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Gerçek görseli göstermek için Image.asset kullanıldı.
    // Placeholder mantığı korunmak istenirse eski yapıya dönülebilir.
    final imageWidget = Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Görsel yüklenemezse placeholder gösterilir.
        return Center(
          child: Text(
            l10n.aiMemeImage,
            style: TextStyle(color: secondaryTextColor),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            caption,
            style: TextStyle(color: primaryTextColor, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, size: 20, color: Colors.red[400]),
                const SizedBox(width: 4),
                Text('$likeCount', style: TextStyle(color: secondaryTextColor)),
                const SizedBox(width: 16),
                Icon(Icons.link, size: 20, color: secondaryTextColor),
              ],
            ),
            Icon(Icons.bookmark_border, size: 20, color: secondaryTextColor),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(radius: 12, backgroundColor: theme.colorScheme.primary.withOpacity(0.5), child: Icon(Icons.person, size: 15, color: theme.iconTheme.color)),
            const SizedBox(width: 8),
            Text(username, style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}