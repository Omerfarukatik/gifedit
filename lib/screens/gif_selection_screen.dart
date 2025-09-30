// lib/screens/gif_selection_screen.dart (ÖNİZLEME EKLENMİŞ, TAM VE HATASIZ HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
// DOĞRU IMPORT YOLU BU.
import 'package:memecreat/screens/result_page.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/image_picker_service.dart';
import '../../theme/app_theme.dart';

class GifSelectionScreen extends StatefulWidget {
  final File userImage;

  const GifSelectionScreen({
    super.key,
    required this.userImage,
  });

  @override
  State<GifSelectionScreen> createState() => _GifSelectionScreenState();
}

class _GifSelectionScreenState extends State<GifSelectionScreen> {
  final ImagePickerService _pickerService = ImagePickerService();
  final ApiService _apiService = ApiService();

  String? _selectedDefaultGif;
  File? _selectedFileGif;
  bool _isLoading = false;

  final List<String> defaultGifs = const [
    'Dans', 'Kızgın', 'Şaşkın', 'Koşma', 'Göz Kırpma', 'Sürpriz',
    "faruk bey", "gülme", "alkış", "mutlu", "üzgün", "şaka", "yemek",
    "uyku", "çalışma"
  ];

  Future<void> _pickUserGif() async {
    // Yükleme sırasında bu fonksiyonun çalışmasını engelle
    if (_isLoading) return;

    final File? gifFile = await _pickerService.pickGifFromGallery();

    if (gifFile != null) {
      setState(() {
        _selectedFileGif = gifFile;
        _selectedDefaultGif = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.gifSelected),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ######################################################################
  // #                                                                    #
  // #           YENİ YARDIMCI WIDGET'LAR ÖNİZLEME İÇİN EKLENDİ           #
  // #                                                                    #
  // ######################################################################

  // YENİ FONKSİYON 1: KULLANICININ SEÇTİĞİ GIF'İ GÖSTEREN WIDGET
  Widget _buildGifPreview() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.yourSelectedGif,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        const SizedBox(height: 15),
        // İşte sihir burada! Seçilen GIF dosyasını ekrana basıyoruz.
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedFileGif!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Kullanıcının fikrini değiştirip şablonlara dönmesi için bir buton
        TextButton.icon(
          icon: const Icon(Icons.grid_view_rounded),
          label: Text(l10n.backToTemplates),
          onPressed: () {
            setState(() {
              _selectedFileGif = null;
            });
          },
        )
      ],
    );
  }

  // YENİ FONKSİYON 2: ŞABLONLARI GÖSTEREN ESKİ GRIDVIEW'İMİZ
  Widget _buildGifGrid() {
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: defaultGifs.length,
      itemBuilder: (context, index) {
        final gifName = defaultGifs[index];
        final isSelected = _selectedDefaultGif == gifName;

        return GestureDetector(
          onTap: () {
            // Yükleme sırasında seçim yapmayı engelle
            if (_isLoading) return;
            setState(() {
              _selectedDefaultGif = gifName;
              _selectedFileGif = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.3) : theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.5),
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.gif_box_rounded,
                  size: 40,
                  color: isSelected ? AppColors.primary : primaryTextColor,
                ),
                const SizedBox(height: 8),
                Text(
                  gifName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createGif() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. GIF seçilmemişse uyar
    if (_selectedDefaultGif == null && _selectedFileGif == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseSelectAGif),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // 2. Yükleme animasyonunu başlat
    setState(() { _isLoading = true; });

    String? resultUrl; // Değişkeni try-catch bloğunun dışında tanımla

    try {
      // 3. Postacıyı (ApiService) çağır ve cevabı değişkene ata.
      resultUrl = await _apiService.createGif(
        userImage: widget.userImage,
        userGif: _selectedFileGif,
        gifTemplateName: _selectedDefaultGif,
      );

    } catch (e) {
      // 4. Postacı yolda bir sorunla karşılaşırsa, hatayı ekrana bas.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      // 5. İşlem bitince (başarılı ya da başarısız), yükleme animasyonunu durdur.
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }

    // 6. EN SON ADIM: Eğer URL başarıyla alındıysa, ŞİMDİ YÖNLENDİR.
    if (mounted && resultUrl != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultPage(resultGifUrl: resultUrl!), // '!' ile null olmadığını garanti et
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectAGifTemplate),
        elevation: 0,
        centerTitle: true,
      ),
      // isLoading true ise tüm ekranı kaplayan bir yükleme animasyonu göster
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Başlık artık dinamik olarak değişecek
                Text(
                  _selectedFileGif == null ? l10n.defaultGifs : l10n.yourGif,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 10),

                // ######################################################################
                // #                                                                    #
                // #              BURASI DEĞİŞTİ: ÖNİZLEME VEYA GRID GÖSTER             #
                // #                                                                    #
                // ######################################################################
                Expanded(
                  // Eğer kullanıcı kendi GIF'ini seçtiyse ÖNİZLEME göster,
                  // seçmediyse ŞABLONLARI (GridView) göster.
                  child: _selectedFileGif != null
                      ? _buildGifPreview() // Önizleme gösterecek yeni fonksiyonumuz
                      : _buildGifGrid(),   // Şablonları gösterecek eski GridView'imiz
                ),


                const SizedBox(height: 20),
                // "Kendi GIF'ini Yükle" butonu sadece şablon ekranındayken görünecek
                if (_selectedFileGif == null)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _pickUserGif, // Yükleme sırasında butonu pasif yap
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
                      foregroundColor: primaryTextColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(l10n.uploadYourOwnGif),
                  ),

                if (_selectedFileGif == null)
                  const SizedBox(height: 15),

                // Oluşturma butonu her zaman görünecek
                ElevatedButton(
                  onPressed: _isLoading ? null : _createGif, // Yükleme sırasında butonu pasif yap
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: Text(l10n.createGif),
                ),
              ],
            ),
          ),
          // YÜKLEME ANİMASYONU EKLENDİ
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
