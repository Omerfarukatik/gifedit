import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GifDetailPage extends StatelessWidget {
  // Bu sayfaya gelirken gönderilecek veriler.
  // Bu verileri kendi modelinle değiştirmelisin (örn: PostModel post).
  final String gifUrl;
  final String userName;
  final String userProfileImageUrl;
  final String description;
  final String postDate;
  final int likeCount;
  final bool isLiked; // Kullanıcının bu gönderiyi beğenip beğenmediği

  const GifDetailPage({
    Key? key,
    required this.gifUrl,
    required this.userName,
    required this.userProfileImageUrl,
    required this.description,
    required this.postDate,
    this.likeCount = 0,
    this.isLiked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Image.network(
              gifUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              // Yüklenirken gösterilecek animasyon
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return AspectRatio(
                  aspectRatio: 16 / 9, // GIF yüklenene kadar sabit bir oran tutar
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary, // Tema vurgu rengin
                    ),
                  ),
                );
              },
              // Hata durumunda gösterilecek widget
              errorBuilder: (context, error, stackTrace) {
                return const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                  _buildUserInfo(),

                  const SizedBox(height: 16),

                  // GÖNDERİ AÇIKLAMASI
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.contentColor, // Temadan gelen beyaz içerik rengi
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                  if (description.isNotEmpty)
                    const SizedBox(height: 16),

                  // AKSİYON BUTONLARI (BEĞEN, YORUM, PAYLAŞ)
                  _buildActionButtons(),

                  const SizedBox(height: 8),

                  // BEĞENİ SAYACI
                  Text(
                    "$likeCount beğeni",
                    style: const TextStyle(
                      color: AppColors.secondaryContentColor, // Temadan gelen gri renk
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // GÖNDERİ TARİHİ
                  Text(
                    postDate,
                    style: const TextStyle(
                      color: AppColors.secondaryContentColor,
                      fontSize: 12,
                    ),
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
  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(userProfileImageUrl),
          // Hata durumunda varsayılan avatar göster
          onBackgroundImageError: (e, s) {},
          backgroundColor: AppColors.backgroundDark.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            userName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.contentColor,
            ),
          ),
        ),
      ],
    );
  }

  // Aksiyon butonlarını oluşturan widget
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Beğen butonu
        IconButton(
          onPressed: () { /* Beğenme fonksiyonunu çağır */ },
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.primary : AppColors.secondaryContentColor,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 20),
        // Yorum butonu
        IconButton(
          onPressed: () { /* Yorumlar sayfasını/alanını aç */ },
          icon: const Icon(
            Icons.comment_outlined,
            color: AppColors.secondaryContentColor,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 20),
        // Paylaş butonu
        IconButton(
          onPressed: () { /* Paylaşma diyalogunu aç */ },
          icon: const Icon(
            Icons.share_outlined,
            color: AppColors.secondaryContentColor,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}