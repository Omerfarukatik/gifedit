// lib/screens/main_screen_wrapper.dart
import 'package:flutter/material.dart';

// Tema ve Renkler
import '../../theme/app_theme.dart'; 

// Tüm ana sayfaları içe aktar
import 'profile_screen.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'gif_upload_screen.dart'; 

// 'Öğren' sekmesi için basit ve TEMA DUYARLI Placeholder
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Rengi temadan alıyoruz
    final primaryTextColor = Theme.of(context).textTheme.bodyMedium!.color;
    
    return Center(
        child: Text(
          "Öğrenme İçerikleri", 
          style: TextStyle(
                fontSize: 24, 
                color: primaryTextColor // Metin rengini temaya göre ayarla
            )
        )
    );
  }
}


class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
 int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const GifUploadScreen(),
    const LearnScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mevcut temadan renkleri alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Navigasyon Çubuğu Arka Plan Rengi: Temaya Duyarlı
    final navBarBackgroundColor = isDark 
      ? const Color(0xFF1B0C27) // Koyu tema için koyu mor/siyah tonu
      : AppColors.cardColorLight; // Açık tema için kart rengi (Beyaz/Açık Gri)
      
    // İkon Renkleri: Temaya Duyarlı
    final selectedColor = theme.colorScheme.primary; // Mor vurgu
    final unselectedColor = theme.hintColor.withOpacity(0.7); // Temaya duyarlı gri

    return Scaffold(
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        // TEMA DUYARLI ARKA PLAN
        backgroundColor: navBarBackgroundColor, 
        
        // TEMA DUYARLI ÖĞE RENKLERİ
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Keşfet'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Oluştur'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Öğren'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}