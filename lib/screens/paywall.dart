// lib/screens/paywall.dart

import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';
import '../../theme/app_theme.dart'; 
import 'main_screen_wrapper.dart'; // Başarılı abonelik sonrası yönlendirme

// ----------------------------------------------------
// VERİ MODELİ
// ----------------------------------------------------
class SubscriptionPlan {
  final String title;
  final double price;
  final String period;
  final List<String> features;
  final bool isBestValue;

  SubscriptionPlan({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.isBestValue = false,
  });
}

// ----------------------------------------------------
// ABONELİK KARTI WIDGET'I (TEMA DUYARLI)
// ----------------------------------------------------
class SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardTextColor = isDark ? Colors.white : AppColors.contentColorLight;
    final cardSecondaryTextColor = isDark ? Colors.white60 : Colors.black54;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? primaryColor.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? primaryColor.withOpacity(0.2) : Colors.grey.shade300), 
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve 'Best Value' etiketi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cardTextColor,
                  ),
                ),
                if (plan.isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'Best Value', // Bu da ARB'de olmalı
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Fiyat
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${plan.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: cardTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/${plan.period}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cardSecondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Özellikler
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plan.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        feature,
                        style: TextStyle(fontSize: 14, color: cardTextColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// PAYWALL ANA SAYFASI
// ----------------------------------------------------
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlan = 'Yearly';

  // Plan verileri (Yerelleştirme metinleri ARB'den okunmalıdır)
  late final List<SubscriptionPlan> plans;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değiştiğinde planları yeniden oluşturmak için (localization'dan metin alımı)
    final l10n = AppLocalizations.of(context)!;
    
    plans = [
      SubscriptionPlan(
        title: 'Weekly', 
        price: 4.99, 
        period: l10n.weekPeriod, // ARB'de olmalı
        features: [l10n.unlimitedMeme, l10n.noWatermarks]
      ),
      SubscriptionPlan(
        title: 'Monthly', 
        price: 19.99, 
        period: l10n.monthPeriod,
        features: [l10n.unlimitedMeme, l10n.noWatermarks, l10n.accessTemplates]
      ),
      SubscriptionPlan(
        title: 'Yearly', 
        price: 49.99, 
        period: l10n.yearPeriod,
        features: [l10n.unlimitedMeme, l10n.noWatermarks, l10n.accessTemplates], 
        isBestValue: true
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color primaryTextColor = theme.textTheme.bodyMedium!.color!;
    final Color secondaryTextColor = theme.hintColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Bölümü: Kapatma Butonu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: secondaryTextColor.withOpacity(0.2), 
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: primaryTextColor),
                    ),
                  ),
                ],
              ),
            ),
            
            // Metin Başlıkları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: l10n.goPremium,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: primaryTextColor,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '→', style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    l10n.proBenefitsDescription, // ARB'den geliyor
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 16, color: secondaryTextColor),
                  ),
                ],
              ),
            ),

            // Plan Listesi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SubscriptionCard(
                        plan: plan,
                        isSelected: _selectedPlan == plan.title,
                        primaryColor: primaryColor,
                        onTap: () {
                          setState(() {
                            _selectedPlan = plan.title;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Alt Kısım: "Go Premium" Butonu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Abonelik işlemini başlat
                  
                  // Başarılı varsayımıyla ana akışa yönlendirme
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
                    (Route<dynamic> route) => false, 
                  );
                },
                child: Text(l10n.goPremium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}