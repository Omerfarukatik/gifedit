// // lib/all_content_screen.dart
// import 'package:flutter/material.dart';
// // Renkleri ve temayı içe aktarmak için (Projenizin yolunuza göre ayarlayın)
// // MemePostCard widget'ını Keşfet sayfasından alalım
// import 'package:memecreat/screens/discover_screen.dart'; 

// class AllContentScreen extends StatelessWidget {
//   // Hangi içeriğin gösterileceğini belirten değişken (Örn: 'Kaydedilenler' veya 'Oluşturulanlar')
//   final String contentType; 

//   const AllContentScreen({super.key, required this.contentType});

//   @override
//   Widget build(BuildContext context) {
//     // Liste için sahte veriler
//     final List<String> items = List.generate(10, (i) => 'Gönderi ${i + 1}');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(contentType), // Başlık dinamik olacak
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           // Bu 'context' artık MemePostCard'a aktarılmalıdır.
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 25.0),
//             child: MemePostCard(
//               // YENİ EKLENEN KISIM: context parametresi
//               context: context, 
//               username: contentType == 'Kaydedilenler' ? 'fav_user_${index + 1}' : 'senin_adın',
//               caption: contentType == 'Kaydedilenler' 
//                   ? 'Kaydettiğim harika bir meme! #${index + 1}'
//                   : 'Kendi oluşturduğum en yeni GIF. Denemelisin!',
//               likeCount: contentType == 'Kaydedilenler' ? 500 + index * 10 : 200 + index * 5,
//               imagePath: 'assets/post_${index + 1}.jpeg', 
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// lib/screens/all_content_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/services/meme_post_card.dart';
class AllContentScreen extends StatelessWidget {
  final String contentType; 

  const AllContentScreen({super.key, required this.contentType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = List.generate(10, (i) => 'Gönderi ${i + 1}');

    return Scaffold(
      appBar: AppBar(
        // Başlık dinamik olarak değişiyor
        title: Text(contentType),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSaved = contentType == l10n.savedMemes;
          return Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MemePostCard(
              username: isSaved ? 'fav_user_${index + 1}' : l10n.username,
              caption: isSaved 
                  ? 'Kaydettiğim harika bir meme! #${index + 1}'
                  : 'Kendi oluşturduğum en yeni GIF. Denemelisin!',
              likeCount: isSaved ? 500 + index * 10 : 200 + index * 5,
              imagePath: 'assets/post_${index + 1}.jpeg', 
            ),
          );
        },
      ),
    );
  }
}