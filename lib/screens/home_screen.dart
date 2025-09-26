// // lib/screens/home_screen.dart
// import 'package:flutter/material.dart';

// // Gerekli sayfalar, servisler ve tema importları
// import 'package:memecreat/screens/all_content_screen.dart';
// import 'package:memecreat/screens/gif_upload_screen.dart';
// import 'package:memecreat/screens/paywall.dart'; // Paywall bağlantısı için
// import 'package:memecreat/theme/app_theme.dart'; 

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   // Hızlı Oluşturma Kartı Widget'ı (TEMA DUYARLI)
//   Widget _buildQuickCreateCard(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;
//     final secondaryTextColor = theme.hintColor;
    
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         // Mor yarı şeffaf arkaplan
//         color: AppColors.primary.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primary, width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hemen Oluşturmaya Başla!',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: primaryTextColor, 
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Yüzünü bir GIF şablonuna işle.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: secondaryTextColor, 
//                 ),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: () {
//                // Yüz Yükleme ekranına yönlendir
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => const GifUploadScreen()),
//                );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.add_circle_outline, size: 20),
//                 SizedBox(width: 5),
//                 Text('Başla'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Günün GIF'i Kartı Widget'ı (TEMA DUYARLI)
//   Widget _buildGifOfTheDayCard(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final secondaryTextColor = theme.hintColor;
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         // Arka plan: Koyu temada koyu kart, Açık temada beyaz kart
//         color: theme.cardColor, 
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.yellow[700]),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Günün GIF\'i',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: primaryTextColor,
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 '25 Eylül',
//                 style: TextStyle(color: secondaryTextColor),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),

//           // GIF Önizleme Alanı
//           Container(
//             height: 180,
//             width: double.infinity,
//             color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade300, 
//             child: Center(
//               child: Text(
//                 'Yüksek Beğenili GIF Önizlemesi',
//                 style: TextStyle(color: secondaryTextColor),
//               ),
//             ),
//           ),
//           const SizedBox(height: 15),

//           // Alt Bilgi
//           Row(
//             children: [
//               Text(
//                 'Kullanıcı Adı',
//                 style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               Row(
//                 children: [
//                   Icon(Icons.favorite, size: 20, color: Colors.red[400]),
//                   const SizedBox(width: 4),
//                   Text('1.5K', style: TextStyle(color: secondaryTextColor)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Premium Promosyon Kartı (TEMA DUYARLI ve PAYWALL BAĞLANTILI)
//   Widget _buildPremiumPromoCard(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         // Sabit, dikkat çekici mor arka plan
//         color: AppColors.primary, 
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filigranları Kaldır!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // Sabit beyaz metin (kontrast için)
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Tüm premium özelliklere erişin.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Paywall ekranına yönlendirme
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const PremiumPage()), 
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white, // Beyaz buton ile kontrast
//               foregroundColor: AppColors.primary, // Mor metin
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             child: const Text('PRO OL'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Bölüm Başlığı Widget'ı (TEMA DUYARLI ve NAVİGASYONLU)
//   Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
//     final theme = Theme.of(context);
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;
//     final secondaryTextColor = theme.hintColor;
    
//     return Row(
//       children: [
//         Icon(icon, color: theme.colorScheme.primary, size: 24),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: primaryTextColor, 
//           ),
//         ),
//         const Spacer(),
//         TextButton(
//           onPressed: () {
//             // Tümünü Gör sayfasına geçiş
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AllContentScreen(contentType: title),
//               ),
//             );
//           },
//           child: Text(
//             'Tümünü Gör',
//             style: TextStyle(color: secondaryTextColor),
//           ),
//         ),
//       ],
//     );
//   }

//   // Yatay İçerik Listesi Widget'ı (TEMA DUYARLI)
//   Widget _buildHorizontalContentList(BuildContext context, String type) {
//     final theme = Theme.of(context);
//     final cardColor = theme.cardColor;
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;

//     return SizedBox(
//       height: 150, 
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 5, 
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 15.0),
//             child: Container(
//               width: 120,
//               decoration: BoxDecoration(
//                 color: cardColor, 
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
//               ),
//               child: Center(
//                 child: Text(
//                   '$type ${index + 1}',
//                   style: TextStyle(color: primaryTextColor),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
  
//   // Ana Widget'ın Build Metodu
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Anasayfa'),
//         elevation: 0,
//         centerTitle: false,
//         actions: const [
//           // İkon rengi temadan gelecek
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.notifications_none),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
            
//             _buildQuickCreateCard(context), // Hızlı Oluşturma Kartı
//             const SizedBox(height: 30),
            
//             _buildPremiumPromoCard(context), // PRO OL Kartı
//             const SizedBox(height: 30),

//             _buildGifOfTheDayCard(context), // Günün GIF'i Kartı
//             const SizedBox(height: 30),
            
//             _buildSectionHeader(context, 'Kaydettiğin Memeler', Icons.bookmark_outline),
//             const SizedBox(height: 10),
//             _buildHorizontalContentList(context, 'Kaydedilen'),
            
//             const SizedBox(height: 30),
            
//             _buildSectionHeader(context, 'Son Oluşturdukların', Icons.history),
//             const SizedBox(height: 10),
//             _buildHorizontalContentList(context, 'Oluşturulan'),

//             const SizedBox(height: 40), 
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'all_content_screen.dart';
import 'gif_upload_screen.dart';
import 'paywall.dart'; 
import '../../theme/app_theme.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.startCreatingNow, // YERELLEŞTİRİLDİ
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor, 
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Yüzünü bir GIF şablonuna işle.', // Bu metin için de bir ARB anahtarı ekleyebilirsiniz
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor, 
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const GifUploadScreen()),
               );
            },
            child: const Text('Başla'), // Bu da yerelleştirilebilir
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
                    l10n.dailyGif, // YERELLEŞTİRİLDİ
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
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
            color: isDark ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade300, 
            child: Center(
              child: Text(
                'Yüksek Beğenili GIF Önizlemesi',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                'Kullanıcı Adı',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.favorite, size: 20, color: Colors.red[400]),
                  const SizedBox(width: 4),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.proBenefitsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Tüm premium özelliklere erişin.', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
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
            child: const Text('PRO OL'),
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
          child: Text(l10n.viewAll, style: TextStyle(color: secondaryTextColor)), // YERELLEŞTİRİLDİ
        ),
      ],
    );
  }

  Widget _buildHorizontalContentList(BuildContext context, String type) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryTextColor = theme.textTheme.bodyMedium!.color;

    return SizedBox(
      height: 150, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, 
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: cardColor, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
              ),
              child: Center(
                child: Text(
                  '$type ${index + 1}',
                  style: TextStyle(color: primaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home), // BAŞLIK YERELLEŞTİRİLDİ
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
            _buildSectionHeader(context, l10n.savedMemes, Icons.bookmark_outline), // BAŞLIK YERELLEŞTİRİLDİ
            const SizedBox(height: 10),
            _buildHorizontalContentList(context, 'Kaydedilen'),
            const SizedBox(height: 30),
            _buildSectionHeader(context, l10n.recentCreations, Icons.history), // BAŞLIK YERELLEŞTİRİLDİ
            const SizedBox(height: 10),
            _buildHorizontalContentList(context, 'Oluşturulan'),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}