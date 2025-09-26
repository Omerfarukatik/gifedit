// lib/screens/subscriptions_screen.dart
import 'package:flutter/material.dart';
import 'package:memecreat/l10n/app_localizations.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  // 1. Abonelik Durumu Kartı (TEMA DUYARLI ve YERELLEŞTİRİLDİ)
  Widget _buildSubscriptionStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyMedium!.color;
    final secondaryTextColor = theme.hintColor;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.3), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentPlanTitle, // YERELLEŞTİRİLDİ
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          
          // Yenileme Tarihi
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.yellow),
              const SizedBox(width: 8),
              Text(
                l10n.nextRenewalDate, // YERELLEŞTİRİLDİ
                style: TextStyle(color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "15 Ekim 2025 ( ${l10n.yearPeriod} )", // YERELLEŞTİRİLDİ
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Özellik Listesi Öğesi (TEMA DUYARLI)
  Widget _buildFeatureItem(BuildContext context, String text) {
    final primaryTextColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: primaryTextColor),
          ),
        ],
      ),
    );
  }

  // Özellikler Listesi Bölümü (YERELLEŞTİRİLDİ)
  Widget _buildFeatureList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proBenefitsListTitle, // YERELLEŞTİRİLDİ
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        _buildFeatureItem(context, l10n.proFeature1), // YERELLEŞTİRİLDİ
        _buildFeatureItem(context, l10n.proFeature2), // YERELLEŞTİRİLDİ
        _buildFeatureItem(context, l10n.proFeature3), // YERELLEŞTİRİLDİ
        _buildFeatureItem(context, l10n.proFeature4), // YERELLEŞTİRİLDİ
      ],
    );
  }


  // Yönetim Butonları (TEMA DUYARLI ve YERELLEŞTİRİLDİ)
  Widget _buildManagementButtons(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor; 
    final secondaryTextColor = theme.hintColor;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: App Store / Play Store Abonelik Yönetimine yönlendir
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cardColor, 
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: theme.colorScheme.primary, width: 1),
            )
          ),
          child: Text(l10n.manageSubscription), // YERELLEŞTİRİLDİ
        ),
        
        const SizedBox(height: 15),
        
        OutlinedButton(
          onPressed: () {
            // TODO: Satın alımları geri yükleme (restore purchases) mantığı
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: secondaryTextColor,
            side: BorderSide(color: secondaryTextColor, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(l10n.restorePurchases), // YERELLEŞTİRİLDİ
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionManagement), // YERELLEŞTİRİLDİ
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSubscriptionStatusCard(context),
            const SizedBox(height: 30),
            
            _buildFeatureList(context),
            
            const SizedBox(height: 30),
            _buildManagementButtons(context),
          ],
        ),
      ),
    );
  }
}