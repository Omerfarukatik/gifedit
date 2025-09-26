// // lib/screens/discover_screen.dart
// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart'; 

// // Not: MemePostCard'ın ya ayrı bir widget klasöründe olması ya da bu dosyanın sonunda tanımlanması gerekir.
// // Temizlik için, MemePostCard'ın bu dosyanın içinde tanımlı olduğunu varsayıyorum.

// class DiscoverScreen extends StatelessWidget {
//   const DiscoverScreen({super.key});

//   // Özel Filtreleme Etiketi (Chip) Oluşturucu (TEMA DUYARLI)
//   Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
//     final theme = Theme.of(context);
    
//     return Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: Chip(
//         label: Text(
//           label, 
//           style: TextStyle(
//             color: isSelected ? AppColors.contentColor : theme.colorScheme.primary // Seçili: Beyaz, Diğerleri: Mor
//           )
//         ),
//         // Seçili ise mor, değilse zemin rengi
//         backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
//         side: BorderSide(
//           color: isSelected ? theme.colorScheme.primary : theme.hintColor.withOpacity(0.5) // Temaya duyarlı kenarlık
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final secondaryTextColor = theme.hintColor;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Keşfet'),
//         elevation: 0,
//         centerTitle: false,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             // İkon rengi temadan otomatik gelecek
//             child: Icon(Icons.filter_list),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 1. Arama Çubuğu (TEMA DUYARLI)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Memeleri ara...',
//                 // TEMA DUYARLI METİN/İKON RENKLERİ
//                 hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
//                 prefixIcon: Icon(Icons.search, color: secondaryTextColor),
//                 filled: true,
//                 // Açık temada beyaz, koyu temada mor gölge
//                 fillColor: theme.brightness == Brightness.dark 
//                     ? AppColors.primary.withOpacity(0.2) 
//                     : theme.cardColor, 
//                 // Kenarlık temadan geliyor
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
//               ),
//             ),
//           ),

//           // 2. Filtreleme Etiketleri
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterChip(context, 'Tümü', isSelected: true),
//                   _buildFilterChip(context, 'A1'),
//                   _buildFilterChip(context, 'A2'),
//                   _buildFilterChip(context, 'B1'),
//                   _buildFilterChip(context, 'B2'),
//                   _buildFilterChip(context, 'C1'),
//                 ],
//               ),
//             ),
//           ),

//           // 3. Meme Akışı
//           Expanded(
//   child: ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//     children: [
//       MemePostCard(
//         context: context,
//         username: 'ahmet_ingilizce',
//         caption: 'Yeni bir İngilizce kelimeyi konuşmada kullanmaya çalıştığımda.',
//         likeCount: 123,
//         // YENİ EKLENEN KISIM: imagePath
//         imagePath: 'assets/post1.jpeg', 
//       ),
//       const SizedBox(height: 20),
//       MemePostCard(
//         context: context,
//         username: 'ayşe_speaks',
//         caption: 'Karmaşık bir dilbilgisi kuralını nihayet anladığımdaki yüz ifadem.',
//         likeCount: 456,
//         // YENİ EKLENEN KISIM: imagePath
//         imagePath: 'assets/post2.jpeg', 
//       ),
//       const SizedBox(height: 20),
//     ],
//   ),
// ),
//         ],
//       ),
//       // BottomNavigationBar MainScreenWrapper'dan geliyor.
//     );
//   }
// }

// // ----------------------------------------------------
// // Meme Kartı (Post Card) Widget'ı (TEMA DUYARLI)
// // ----------------------------------------------------
// class MemePostCard extends StatelessWidget {
//   final BuildContext context;
//   final String username;
//   final String caption;
//   final int likeCount;

//   const MemePostCard({
//     super.key,
//     required this.context,
//     required this.username,
//     required this.caption,
//     required this.likeCount, required String imagePath,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryTextColor = theme.textTheme.bodyMedium!.color;
//     final secondaryTextColor = theme.hintColor;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Görselin Bulunduğu Kısım
//         Container(
//           height: 350, 
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             // Açık temada daha nötr bir renk
//             color: theme.brightness == Brightness.dark 
//                 ? AppColors.primary.withOpacity(0.2) 
//                 : Colors.grey.shade200, 
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Center(
//               child: Text(
//                 'AI/Meme Görseli', 
//                 style: TextStyle(color: secondaryTextColor),
//               ), 
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 12),

//         // Başlık (Caption)
//         Padding(
//           padding: const EdgeInsets.only(left: 4.0),
//           child: Text(
//             caption,
//             style: TextStyle(
//               // TEMA DUYARLI METİN
//               color: primaryTextColor, 
//               fontSize: 16,
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 8),

//         // Aksiyon Butonları (Beğeni, Paylaş, Kaydet)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 // Beğeni (Like)
//                 Row(
//                   children: [
//                     Icon(Icons.favorite, size: 20, color: Colors.red[400]),
//                     const SizedBox(width: 4),
//                     // TEMA DUYARLI METİN
//                     Text('$likeCount', style: TextStyle(color: secondaryTextColor)),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 // Paylaş/Kopyala
//                 Icon(Icons.link, size: 20, color: secondaryTextColor),
//               ],
//             ),
            
//             // Kaydet (Bookmark)
//             Icon(Icons.bookmark_border, size: 20, color: secondaryTextColor),
//           ],
//         ),
        
//         const SizedBox(height: 12),
        
//         // Kullanıcı Adı
//         Row(
//           children: [
//             // Kullanıcı Avatarı Placeholder
//             CircleAvatar(
//               radius: 12,
//               backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
//               child: Icon(Icons.person, size: 15, color: theme.iconTheme.color),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               username,
//               style: TextStyle(
//                 // TEMA DUYARLI METİN
//                 color: primaryTextColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// lib/screens/discover_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import '../../theme/app_theme.dart'; 

// Not: MemePostCard'ın bu dosyada veya ayrı bir widget dosyasında olması gerekir.
// Temizlik için, MemePostCard'ın bu dosyanın içinde tanımlı olduğunu varsayıyorum.

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label, 
          style: TextStyle(
            color: isSelected ? AppColors.contentColor : theme.colorScheme.primary
          )
        ),
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.hintColor.withOpacity(isDark ? 0.5 : 0.2)
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final secondaryTextColor = theme.hintColor;
  

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover), // BAŞLIK YERELLEŞTİRİLDİ
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchMemes, // HINT TEXT YERELLEŞTİRİLDİ
                hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),

          // Filtreleme Etiketleri (Static kaldığı için yerelleştirmeye gerek yok)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, l10n.all, isSelected: true), // YENİ: 'Tümü' için key
                  _buildFilterChip(context, 'A1'),
                  _buildFilterChip(context, 'A2'),
                  _buildFilterChip(context, 'B1'),
                  _buildFilterChip(context, 'B2'),
                  _buildFilterChip(context, 'C1'),
                ],
              ),
            ),
          ),

          // Meme Akışı
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              children: [
                MemePostCard(
                  context: context,
                  username: l10n.ahmet, // Örnek metinler için arb'a key ekleyebilirsiniz.
                  caption: l10n.memeCaption1,
                  likeCount: 123,
                  imagePath: 'assets/dog.jpeg',
                ),
                const SizedBox(height: 20),
                MemePostCard(
                  context: context,
                  username: l10n.ayse,
                  caption: l10n.memeCaption2,
                  likeCount: 456,
                  imagePath: 'assets/cat.jpeg',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemePostCard extends StatelessWidget {
  final BuildContext context;
  final String username;
  final String caption;
  final int likeCount;
  final String imagePath;

  const MemePostCard({
    super.key,
    required this.context,
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
            child: Center(
              child: Text(
                l10n.aiMemeImage, // YERELLEŞTİRİLDİ
                style: TextStyle(color: secondaryTextColor),
              ), 
            ),
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
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
              child: Icon(Icons.person, size: 15, color: theme.iconTheme.color),
            ),
            const SizedBox(width: 8),
            Text(
              username,
              style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}