import 'package:flutter/material.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart'; // <<<<<<< BU SATIRI EKLE

// Sayfa artık state'i (kaydetme durumu) yöneteceği için StatefulWidget'a dönüştü.
class GifDetailPage extends StatelessWidget {
  // Kaydetme işlemi için tüm GIF verisine ihtiyacımız var.
  final Map<String, dynamic> gifData;
  final String gifUrl;
  final String userName;
  final String userProfileImageUrl;
  final String description;
  final String postDate;

  const GifDetailPage({
    Key? key,
    required this.gifData,
    required this.gifUrl,
    required this.userName,
    required this.userProfileImageUrl,
    required this.description,
    required this.postDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider'ları build metodu içinde tanımlıyoruz.
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);
    final theme = Theme.of(context); // Temayı alıyoruz.

    // Scaffold'un temel rengi temanızdan (AppTheme.darkTheme) otomatik olarak gelecektir.
    return Scaffold(
      appBar: AppBar(
        // AppTheme'deki appBarTheme ayarları sayesinde başlık ve ikon renkleri otomatik ayarlanır.
        // Geri butonu Navigator.push ile gelindiği için otomatik eklenir.
        title: const Text("Gönderi"),
        actions: [
          // Gönderi sahibi ise silme veya düzenleme butonu gibi bir ikon eklenebilir.
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // Silme, düzenleme, bildirme gibi seçeneklerin olduğu bir menu göster.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GIF GÖSTERİM ALANI
            CachedNetworkImage(
              imageUrl: gifUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              // Yüklenirken gösterilecek animasyon
              placeholder: (context, url) => AspectRatio(
                aspectRatio: 16 / 9, // GIF yüklenene kadar sabit bir oran tutar
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary, // Tema vurgu rengin
                  ),
                ),
              ),
              // Hata durumunda gösterilecek widget
              errorWidget: (context, url, error) {
                // Hata ayıklama için konsola detaylı bilgi yazdır.
                debugPrint('--- GIF YÜKLENİRKEN HATA (GifDetailPage) ---');
                debugPrint('URL: $url'); // 'url' parametresini kullan
                debugPrint('Hata: $error');
                debugPrint('------------------------------------------');

                // Arayüzde kullanıcıya daha anlaşılır bir hata göster.
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16.0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'GIF yüklenemedi.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 2. KULLANICI, AÇIKLAMA ve AKSİYONLAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KULLANICI BİLGİSİ
                  _buildUserInfo(context),

                  const SizedBox(height: 16),

                  // GÖNDERİ AÇIKLAMASI
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                  if (description.isNotEmpty)
                    const SizedBox(height: 16),

                  // GÖNDERİ TARİHİ
                  Text(
                    postDate,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32), // Sayfa sonuna boşluk
          ],
        ),
      ),
    );
  }

  // Kullanıcı bilgisini gösteren özel bir widget
  Widget _buildUserInfo(BuildContext context) {
    // Provider'ı burada da alıyoruz ki butonu oluşturabilelim.
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);
    final theme = Theme.of(context); // Temayı alıyoruz.

    // HATA DÜZELTMESİ: Profil fotoğrafı URL'sinin boş olup olmadığını kontrol et.
    final bool hasProfileImage = userProfileImageUrl.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          // URL boş değilse resmi yükle, boşsa null ata.
          backgroundImage: hasProfileImage ? NetworkImage(userProfileImageUrl) : null,
          backgroundColor: AppColors.backgroundDark.withOpacity(0.7),
          // Eğer resim yoksa (backgroundImage null ise), varsayılan bir ikon göster.
          child: !hasProfileImage
              ? const Icon(Icons.person, size: 28, color: AppColors.secondaryContentColor)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            userName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // DEĞİŞİKLİK: Kaydet butonu buraya taşındı.
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            final gifId = gifData['id'] as String? ?? '';
            final isSaved = profileProvider.isGifSaved(gifId);
            final isProcessing = profileProvider.isProcessingSave(gifId);

            return _buildActionButton(
              context,
              icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
              // label'ı kaldırarak sadece ikon gösteriyoruz.
              color: isSaved ? AppColors.primary : null,
              onPressed: isProcessing
                  ? null
                  : () => profileProviderForActions.toggleSaveGif(gifData),
            );
          },
        ),
      ],
    );
  }

  // MemePostCard'daki ile benzer bir buton oluşturma fonksiyonu.
  Widget _buildActionButton(BuildContext context, {required IconData icon, String? label, Color? color, VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row'un içeriği kadar yer kaplamasını sağlar.
          children: [
            // Eğer işlem devam ediyorsa (onPressed null ise) spinner göster.
            onPressed == null
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Icon(icon, color: color ?? theme.iconTheme.color, size: 24),
            if (label != null && label.isNotEmpty) ...[
              const SizedBox(width: 12.0),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color ?? theme.textTheme.bodyMedium?.color),
              )
            ],
          ],
        ),
      ),
    );
  }
}