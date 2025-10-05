import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memecreat/screens/gif_selection_screen.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/services/api_service.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Sayfa, Remix işlemi sırasında yükleme durumunu yöneteceği için StatefulWidget'a dönüştürüldü.
class GifDetailPage extends StatefulWidget {
  // Hem kaydetme hem de remix işlemi için tüm GIF verisine ihtiyacımız var.
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
  State<GifDetailPage> createState() => _GifDetailPageState();
}

class _GifDetailPageState extends State<GifDetailPage> {
  // Sadece bu sayfanın sorumluluğunda olan state değişkeni.
  bool _isCreatingRemix = false;

  // ApiService'in bir örneğini oluşturuyoruz.
  // Daha gelişmiş bir yapıda bu, GetIt gibi bir DI (Dependency Injection) ile sağlanabilir.
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gönderi"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildUseGifButton(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GIF GÖSTERİM ALANI
            CachedNetworkImage(
              imageUrl: widget.gifUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => AspectRatio(
                aspectRatio: 16 / 9,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (context, url, error) {
                // Hata durumu için widget (senin kodundakiyle aynı)
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
                        Text('GIF yüklenemedi.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  _buildUserInfo(context),
                  const SizedBox(height: 16),
                  if (widget.description.isNotEmpty)
                    Text(
                      widget.description,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                    ),
                  if (widget.description.isNotEmpty) const SizedBox(height: 16),
                  Text(
                    widget.postDate,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // FloatingActionButton'un içeriği kaplamaması için en alta boşluk ekleyelim.
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- Buton ve Remix Mantığı ---

  /// "Bu GIF'i Kullan" butonunu oluşturan widget.
  Widget _buildUseGifButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Remix işlemi sürüyorsa, bir yükleme animasyonu göster.
    if (_isCreatingRemix) {
      return FloatingActionButton.extended(
        onPressed: null, // Butonu pasif yap
        label: Text(l10n.creating), // "Oluşturuluyor..."
        icon: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }
    // Normal durumdaki buton
    return FloatingActionButton.extended(
      onPressed: () => _useThisGifTemplate(context), // Tıklandığında ana mantığı çağır
      label: Text(l10n.useThisGif), // "Bu GIF'i Kullan"
      icon: const Icon(Icons.add_photo_alternate_outlined),
    );
  }

  /// Butona tıklandığında çalışan ana Remix mantığı.
  Future<void> _useThisGifTemplate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // 1. Orijinal şablon URL'sini al.
    final templateImageUrl = widget.gifData['templateImageUrl'] as String?;

    if (templateImageUrl == null || templateImageUrl.isEmpty) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.templateNotFound), backgroundColor: Colors.red));
      return;
    }

    // 2. Galeriden YENİ yüz resmini seçtir.
    final picker = ImagePicker();
    final XFile? faceImageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (faceImageFile == null) return; // Kullanıcı vazgeçti.

    // 3. ApiService'i burada çağırmak yerine, kullanıcıyı sihirli bekleme
    // ekranına yönlendiriyoruz. İşlemi o devralacak.
    if (mounted) {
      // ÖNEMLİ: GifSelectionScreen'ı import etmeyi unutma!
      // Dosyanın başına şunu ekle: import 'package:memecreat/screens/gif_selection_screen.dart';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GifSelectionScreen(
            userImage: File(faceImageFile.path), // Yeni seçilen yüz
            startInLoadingMode: true, // <-- SİHİRLİ KOMUT 1
            initialTemplateUrl:
            templateImageUrl, // <-- SİHİRLİ KOMUT 2
          ),
        ),
      );
    }
  }


  // --- Yardımcı Widget'lar (Değişmedi) ---

  /// Kullanıcı bilgisini ve kaydetme butonunu gösteren widget.
  Widget _buildUserInfo(BuildContext context) {
    final profileProviderForActions = Provider.of<ProfileProvider>(context, listen: false);
    final theme = Theme.of(context);
    final bool hasProfileImage = widget.userProfileImageUrl.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: hasProfileImage ? CachedNetworkImageProvider(widget.userProfileImageUrl) : null,
          backgroundColor: AppColors.backgroundDark.withOpacity(0.7),
          child: !hasProfileImage ? const Icon(Icons.person, size: 28, color: AppColors.secondaryContentColor) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.userName,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // Kaydetme butonu, kendi state'ini ProfileProvider'dan dinlemeye devam ediyor.
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            final gifId = widget.gifData['id'] as String? ?? '';
            final isSaved = profileProvider.isGifSaved(gifId);
            final isProcessing = profileProvider.isProcessingSave(gifId);

            return _buildActionButton(
              context,
              icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? AppColors.primary : null,
              onPressed: isProcessing ? null : () => profileProviderForActions.toggleSaveGif(widget.gifData),
            );
          },
        ),
      ],
    );
  }

  /// Sadece kaydetme butonu için kullanılan küçük aksiyon butonu.
  Widget _buildActionButton(BuildContext context, {required IconData icon, Color? color, VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: onPressed == null
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
            : Icon(icon, color: color ?? theme.iconTheme.color, size: 28),
      ),
    );
  }
}
