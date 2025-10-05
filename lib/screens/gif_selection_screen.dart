// lib/screens/gif_selection_screen.dart (530+ SATIRLIK GERÇEKTEN SON VE NİHAİ VERSİYON)

import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memecreat/core/app_constants.dart';
import 'package:memecreat/screens/result_page.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/image_picker_service.dart';
import '../../theme/app_theme.dart';

// === WIDGET TANIMI AYNI ===
class GifSelectionScreen extends StatefulWidget {
  final File userImage;
  final bool startInLoadingMode;
  final String? initialTemplateUrl;

  const GifSelectionScreen({
    super.key,
    required this.userImage,
    this.startInLoadingMode = false,
    this.initialTemplateUrl,
  });

  @override
  State<GifSelectionScreen> createState() => _GifSelectionScreenState();
}

class _GifSelectionScreenState extends State<GifSelectionScreen>
    with TickerProviderStateMixin {
  // === STATE ve FONKSİYONLAR AYNI ===
  final ImagePickerService _pickerService = ImagePickerService();
  final ApiService _apiService = ApiService();

  String? _selectedDefaultGif;
  File? _selectedFileGif;
  bool _isLoading = false;
  bool _startAnimation = false;

  final List<String> defaultGifs = AppConstants.defaultGifUrls;

  @override
  void initState() {
    super.initState();
    if (widget.startInLoadingMode && widget.initialTemplateUrl != null) {
      _isLoading = true;
      _startAnimation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createGif(remixTemplateUrl: widget.initialTemplateUrl);
      });
    }
  }

  Future<File?> _downloadGif(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint("GIF indirme hatası: $e");
    }
    return null;
  }

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

  Future<void> _createGif({String? remixTemplateUrl}) async {
    final l10n = AppLocalizations.of(context)!;
    if (remixTemplateUrl == null &&
        _selectedDefaultGif == null &&
        _selectedFileGif == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseSelectAGif),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!widget.startInLoadingMode) {
      setState(() {
        _isLoading = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _startAnimation = true);
        });
      });
    }

    String? resultUrl;
    try {
      resultUrl = await _apiService.createGif(
        userImage: widget.userImage,
        userGif: _selectedFileGif,
        gifTemplateName: _selectedDefaultGif,
        gifTemplateUrl: remixTemplateUrl,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    }

    if (mounted && resultUrl != null) {
      await precacheImage(NetworkImage(resultUrl), context);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultPage(resultGifUrl: resultUrl!),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _startAnimation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
        title: Text(l10n.selectAGifTemplate),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingScreen(context)
          : _buildSelectionUI(context),
    );
  }

  Widget _buildSelectionUI(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              _selectedFileGif == null ? l10n.defaultGifs : l10n.yourGif,
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
          MagicCreateButton(
              isLoading: _isLoading,
              // onPressed bir VoidCallback bekler, _createGif ise parametreli.
              // Bu yüzden anonim bir fonksiyonla sarmalıyoruz.
              onPressed: () => _createGif()),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }

  Widget _buildGifPreview() {
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

class MagicCreateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const MagicCreateButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      icon: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.auto_awesome),
      // === DÜZELTME 1: YANLIŞ l10n string'i DOĞRUSUYLA DEĞİŞTİRİLDİ ===
      label: Text(AppLocalizations.of(context)!.createGif),
    );
  }
}

class BubblePainter extends StatefulWidget {
  const BubblePainter({super.key});
  @override
  State<BubblePainter> createState() => _BubblePainterState();
}

class _BubblePainterState extends State<BubblePainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Bubble> bubbles = [];
  final int numberOfBubbles = 30;
  final Random random = Random();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    for (int i = 0; i < numberOfBubbles; i++) {
      bubbles.add(Bubble(random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _MyPainter(bubbles, random, _controller.value),
        );
      },
    );
  }
}

class _MyPainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Random random;
  final double animationValue;
  _MyPainter(this.bubbles, this.random, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      bubble.update(animationValue, size);
      final paint = Paint()
        ..color = bubble.color.withOpacity(bubble.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bubble.x, bubble.y), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Bubble {
  late double x, y;
  late double size;
  late Color color;
  late double speed;
  late double opacity;
  final Random random;
  Bubble(this.random) {
    reset();
  }
  void reset({Size? size}) {
    x = random.nextDouble() * (size?.width ?? 0);
    y = (size?.height ?? 0) + random.nextDouble() * 100 + 50;
    // === DÜZELTME 2: `as Size?` hatası KALDIRILDI. Bu atama bir double'a yapılmalı. ===
    this.size = random.nextDouble() * 20 + 5;
    color =
        Colors.primaries[random.nextInt(Colors.primaries.length)].withAlpha(150);
    speed = random.nextDouble() * 1.5 + 0.5;
    opacity = random.nextDouble() * 0.5 + 0.1;
  }

  void update(double animationValue, Size size) {
    y -= speed;
    if (y < -size.height * 0.1) {
      reset(size: size);
    }
  }
}
