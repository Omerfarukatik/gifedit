// lib/screens/gif_selection_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // <-- GEREKLİ IMPORT
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart'; // <-- GEREKLİ IMPORT
import 'package:memecreat/core/app_constants.dart';
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

class _GifSelectionScreenState extends State<GifSelectionScreen> with TickerProviderStateMixin {
  final ImagePickerService _pickerService = ImagePickerService();
  final ApiService _apiService = ApiService();

  String? _selectedDefaultGif;
  File? _selectedFileGif;
  bool _isLoading = false;
  bool _startAnimation = false;

  final List<String> defaultGifs = AppConstants.defaultGifUrls;

  // --- YENİ FONKSİYON: URL'den GIF indirip File nesnesine çevirir ---
  Future<File?> _downloadGif(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        // Dosyaya benzersiz bir isim verelim
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("GIF indirildi ve geçici dosyaya yazıldı: ${file.path}");
        return file;
      } else {
        debugPrint("GIF indirme hatası: Sunucu ${response.statusCode} durum kodu döndü.");
      }
    } catch (e) {
      debugPrint("GIF indirme sırasında istisna oluştu: $e");
    }
    return null;
  }
  // -------------------------------------------------------------

  Future<void> _pickUserGif() async {
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

  // --- _createGif FONKSİYONU GÜNCELLENDİ ---
  Future<void> _createGif() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDefaultGif == null && _selectedFileGif == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseSelectAGif),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _startAnimation = true);
      });
    });

    File? gifToSend;
    bool isTemporaryFile = false;

    // Senaryo 1: Kullanıcı galeriden bir GIF seçti.
    if (_selectedFileGif != null) {
      gifToSend = _selectedFileGif;
    }
    // Senaryo 2: Kullanıcı hazır listeden bir GIF (URL) seçti.
    else if (_selectedDefaultGif != null) {
      gifToSend = await _downloadGif(_selectedDefaultGif!);
      isTemporaryFile = gifToSend != null;
    }

    if (gifToSend == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Seçilen GIF işlenemedi. Lütfen tekrar deneyin."),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
          _startAnimation = false;
        });
      }
      return;
    }

    String? resultUrl;
    try {
      resultUrl = await _apiService.createGif(
        userImage: widget.userImage,
        userGif: gifToSend, // <-- API'ye artık her zaman bir DOSYA gönderiliyor.
        gifTemplateName: null, // Bu parametreye artık ihtiyaç yok, null gönderilebilir.
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      // İşlem bitince, geçici olarak indirilen dosyayı silerek temizlik yap.
      if (isTemporaryFile) {
        await gifToSend.delete();
        debugPrint("Geçici GIF dosyası silindi.");
      }
    }

    if (mounted && resultUrl != null) {
      try {
        await precacheImage(
          NetworkImage(resultUrl),
          context,
          onError: (exception, stackTrace) {
            debugPrint("Precache Hatası: GIF yüklenemedi. $exception");
          },
        );
      } catch (e) {
        debugPrint("Precache sırasında genel bir hata oluştu: $e");
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(resultGifUrl: resultUrl!),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _startAnimation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // build metodu ve içeriği değişmedi
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
        title: Text(l10n.selectAGifTemplate),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    _selectedFileGif == null
                        ? l10n.defaultGifs
                        : l10n.yourGif,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor)),
                const SizedBox(height: 10),
                Expanded(
                    child: _selectedFileGif != null
                        ? _buildGifPreview()
                        : _buildGifGrid()),
                const SizedBox(height: 20),
                if (_selectedFileGif == null)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _pickUserGif,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      foregroundColor: primaryTextColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(l10n.uploadYourOwnGif),
                  ),
                if (_selectedFileGif == null) const SizedBox(height: 15),
                MagicCreateButton(isLoading: _isLoading, onPressed: _createGif),
              ],
            ),
          ),
          if (_isLoading)
            Stack(
              children: [
                Container(color: Colors.black),
                const BubblePainter(),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutQuint,
                  top: _startAnimation
                      ? MediaQuery.of(context).size.height / 2 - 200
                      : -300,
                  left: 0,
                  right: 0,
                  child: Lottie.asset('assets/animations/magic_loading_2.json',
                      width: 250, height: 250),
                ),
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1200),
                    opacity: _startAnimation ? 1.0 : 0.0,
                    child: Column(
                      children: [
                        Text(
                          l10n.creatingYourMasterpiece,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          l10n.thisMayTakeAMoment,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGifPreview() {
    // Bu widget değişmedi
    final l10n = AppLocalizations.of(context)!;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(l10n.yourSelectedGif,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color)),
      const SizedBox(height: 15),
      Expanded(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_selectedFileGif!, fit: BoxFit.contain))),
      const SizedBox(height: 15),
      TextButton.icon(
          icon: const Icon(Icons.grid_view_rounded),
          label: Text(l10n.backToTemplates),
          onPressed: () => setState(() => _selectedFileGif = null))
    ]);
  }

  Widget _buildGifGrid() {
    // Bu widget değişmedi
    final theme = Theme.of(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: defaultGifs.length,
      itemBuilder: (context, index) {
        final gifUrl = defaultGifs[index];
        final isSelected = _selectedDefaultGif == gifUrl;

        return GestureDetector(
          onTap: () {
            if (_isLoading) return;
            setState(() {
              _selectedDefaultGif = gifUrl;
              _selectedFileGif = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CachedNetworkImage(
                imageUrl: gifUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.cardColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }
}

// === DOSYANIN GERİ KALANI DEĞİŞMEDİ ===

class MagicCreateButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const MagicCreateButton(
      {Key? key, required this.onPressed, this.isLoading = false})
      : super(key: key);
  @override
  _MagicCreateButtonState createState() => _MagicCreateButtonState();
}

class _MagicCreateButtonState extends State<MagicCreateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 2)
                ]),
            child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: widget.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.createGif,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)))));
  }
}

class Bubble {
  late AnimationController controller;
  late Animation<double> radius;
  late Animation<double> opacity;
  final Color color;
  final double maxSize;
  final Duration duration;
  late Alignment begin;
  late Alignment end;

  Bubble(
      {required TickerProvider vsync,
        required this.color,
        required this.maxSize})
      : duration = Duration(milliseconds: 2000 + Random().nextInt(3000)) {
    controller = AnimationController(vsync: vsync, duration: duration);
    radius = Tween<double>(begin: 1.0, end: maxSize)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    begin =
        Alignment(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1);
    end =
        Alignment(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1);
  }

  void dispose() {
    controller.dispose();
  }
}

class BubblePainter extends StatefulWidget {
  final int bubbleCount;
  const BubblePainter({super.key, this.bubbleCount = 20});

  @override
  _BubblePainterState createState() => _BubblePainterState();
}

class _BubblePainterState extends State<BubblePainter>
    with TickerProviderStateMixin {
  late List<Bubble> bubbles;

  @override
  void initState() {
    super.initState();
    bubbles = List.generate(widget.bubbleCount, (index) {
      final bubble = Bubble(
        vsync: this,
        color: AppColors.primary.withOpacity(Random().nextDouble() * 0.4 + 0.1),
        maxSize: 15.0 + Random().nextDouble() * 30.0,
      );
      bubble.controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: Random().nextInt(800)), () {
            if (mounted) {
              bubble.controller.reset();
              bubble.controller.forward();
            }
          });
        }
      });
      Future.delayed(Duration(milliseconds: Random().nextInt(2000)), () {
        if (mounted) bubble.controller.forward();
      });
      return bubble;
    });
  }

  @override
  void dispose() {
    for (var bubble in bubbles) {
      bubble.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblesCustomPainter(bubbles: bubbles),
      child: Container(),
    );
  }
}

class _BubblesCustomPainter extends CustomPainter {
  final List<Bubble> bubbles;

  _BubblesCustomPainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color.withOpacity(bubble.opacity.value)
        ..style = PaintingStyle.fill;

      final offset = Alignment.lerp(
          bubble.begin, bubble.end, bubble.controller.value)!
          .alongSize(size);
      canvas.drawCircle(offset, bubble.radius.value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}