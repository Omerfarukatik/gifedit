import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'gif_detail_page.dart';
import 'all_content_screen.dart';
import 'gif_upload_screen.dart';
import 'paywall.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TEK, DOĞRU build METODU
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ProfileProvider'ı dinleyerek canlı verilere ulaşıyoruz.
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Provider'dan gelen gerçek listeleri alalım.
        final createdGifs = profileProvider.createdGifs;
        final savedGifs = profileProvider.savedGifs;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.home), // Yerelleştirildi
            elevation: 0,
            centerTitle: false,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.notifications_none),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildQuickCreateCard(context),
                const SizedBox(height: 30),
                _buildPremiumPromoCard(context),
                const SizedBox(height: 30),
                _buildGifOfTheDayCard(context),
                const SizedBox(height: 30),

                // "Kaydettiğin Memeler" bölümü
                _buildSectionHeader(
                    context, l10n.savedMemes, Icons.bookmark_outline),
                const SizedBox(height: 10),
                _buildHorizontalContentList(context, savedGifs),

                const SizedBox(height: 30),

                // "Son Oluşturdukların" bölümü
                _buildSectionHeader(
                    context, l10n.recentCreations, Icons.history),
                const SizedBox(height: 10),
                _buildHorizontalContentList(context, createdGifs),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- YARDIMCI WIDGET'LAR (TEMİZ VE YERELLEŞTİRİLMİŞ) ---

  Widget _buildQuickCreateCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.startCreatingNow,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.processYourFace,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GifUploadScreen()),
              );
            },
            child: Text(l10n.start),
          ),
        ],
      ),
    );
  }

  Widget _buildGifOfTheDayCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = theme.hintColor;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow[700]),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dailyGif,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
              // TODO: Bu tarihi dinamik yap
              Text(
                '25 Eylül',
                style: TextStyle(color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                l10n.gifPreview,
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // TODO: Bu kullanıcı adını dinamik yap
              Text(
                'Kullanıcı Adı',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.favorite, size: 20, color: Colors.red[400]),
                  const SizedBox(width: 4),
                  // TODO: Bu beğeni sayısını dinamik yap
                  Text('1.5K', style: TextStyle(color: secondaryTextColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPromoCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.proBenefitsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(l10n.proBenefitsSubtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaywallScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(l10n.goPro),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllContentScreen(contentType: title)));
          },
          child: Text(l10n.viewAll, style: TextStyle(color: secondaryTextColor)),
        ),
      ],
    );
  }

  Widget _buildHorizontalContentList(
      BuildContext context, List<Map<String, dynamic>> gifs) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    if (gifs.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          l10n.nothingHereYet,
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gifs.length > 5 ? 5 : gifs.length, // En fazla 5 tane gösterelim.
        itemBuilder: (context, index) {
          final gifData = gifs[index];
          final gifUrl = gifData['gifUrl'] as String?;

          // --- DEĞİŞİKLİK: Tıklama işlevselliği için GestureDetector eklendi ---
          return GestureDetector(
            onTap: () {
              if (gifUrl == null) return;
              // Detay sayfasına yönlendirme mantığı (diğer ekranlardaki gibi)
              final username = gifData['creatorUsername'] ?? 'bilinmiyor';
              final userAvatarUrl = gifData['creatorProfileUrl'] as String? ?? '';
              final caption = gifData['caption'] as String? ?? '';
              final postTimestamp = gifData['createdAt'] as Timestamp?;
              final postDate = postTimestamp?.toDate();
              final timeAgoString = postDate != null ? timeago.format(postDate, locale: Localizations.localeOf(context).languageCode) : '';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifDetailPage(
                    gifData: gifData,
                    gifUrl: gifUrl,
                    userName: username,
                    userProfileImageUrl: userAvatarUrl,
                    description: caption,
                    postDate: timeAgoString,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: AspectRatio(
                aspectRatio: 9 / 16, // Dikey bir oran
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
                    ),
                    child: gifUrl != null
                        ? CachedNetworkImage(
                            key: ValueKey(gifUrl),
                            imageUrl: gifUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : Center(
                            child: Text(l10n.gifNotFound, style: TextStyle(color: theme.hintColor), textAlign: TextAlign.center),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
