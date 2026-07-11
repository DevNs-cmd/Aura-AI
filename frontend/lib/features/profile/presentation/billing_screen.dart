import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../billing_provider.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(billingProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final locale = Localizations.localeOf(context).languageCode;

    // Translation registry
    String title = 'Billing & Subscription';
    String currentPlan = 'Current Plan';
    String freePlan = 'Free Tier';
    String premiumPlan = 'Premium Tier';
    String usageLimits = 'Usage Limits';
    String chatUsage = 'AI Companion Chats';
    String memoryUsage = 'Memory Index Slots';
    String upgradeBtn = 'Upgrade to Premium (\$9.99/mo)';
    String cancelBtn = 'Cancel Premium Subscription';
    String premiumBenefits = 'Premium Benefits Included';
    String b1 = 'Unlimited Smart Memories & Goals';
    String b2 = 'Ad-Free Full Experience';
    String b3 = 'Priority High-Speed AI Processing';
    String b4 = 'Custom AI Personality Dialers';
    String manageBilling = 'Manage Payments';

    switch (locale) {
      case 'es':
        title = 'Facturación y suscripción';
        currentPlan = 'Plan actual';
        freePlan = 'Plan Gratuito';
        premiumPlan = 'Plan Premium';
        usageLimits = 'Límites de uso';
        chatUsage = 'Chats con Compañero IA';
        memoryUsage = 'Ranuras de Memoria';
        upgradeBtn = 'Mejorar a Premium (\$9.99/mes)';
        cancelBtn = 'Cancelar Suscripción Premium';
        premiumBenefits = 'Beneficios Premium Incluidos';
        b1 = 'Recuerdos y Metas Inteligentes Ilimitadas';
        b2 = 'Experiencia Completa Sin Anuncios';
        b3 = 'Procesamiento de IA Prioritario';
        b4 = 'Personalidades de IA Personalizadas';
        manageBilling = 'Administrar Pagos';
        break;
      case 'hi':
        title = 'बिलिंग और सदस्यता';
        currentPlan = 'वर्तमान योजना';
        freePlan = 'मुफ़्त योजना';
        premiumPlan = 'प्रीमियम योजना';
        usageLimits = 'उपयोग सीमाएँ';
        chatUsage = 'एआई चैट साथी';
        memoryUsage = 'मेमोरी इंडेक्स स्लॉट';
        upgradeBtn = 'प्रीमियम में अपग्रेड करें (\$9.99/माह)';
        cancelBtn = 'प्रीमियम सदस्यता रद्द करें';
        premiumBenefits = 'प्रीमियम लाभ शामिल हैं';
        b1 = 'असीमित यादें और लक्ष्य';
        b2 = 'विज्ञापन-मुक्त संपूर्ण अनुभव';
        b3 = 'प्राथमिकता एआई प्रतिक्रियाएं';
        b4 = 'कस्टम एआई व्यक्तित्व सेटिंग्स';
        manageBilling = 'भुगतान प्रबंधित करें';
        break;
      case 'fr':
        title = 'Facturation et abonnement';
        currentPlan = 'Plan Actuel';
        freePlan = 'Plan Gratuit';
        premiumPlan = 'Plan Premium';
        usageLimits = 'Limites d\'Utilisation';
        chatUsage = 'Discussions Compagnon IA';
        memoryUsage = 'Emplacements de Mémoire';
        upgradeBtn = 'Passer à Premium (9,99 \$/mois)';
        cancelBtn = 'Annuler l\'Abonnement Premium';
        premiumBenefits = 'Avantages Premium Inclus';
        b1 = 'Souvenirs & Objectifs Illimités';
        b2 = 'Expérience Completa Sans Publicité';
        b3 = 'Traitement IA Haute Vitesse Prioritaire';
        b4 = 'Personnalités IA Personnalisables';
        manageBilling = 'Gérer les Paiements';
        break;
      case 'de':
        title = 'Abrechnung & Abo';
        currentPlan = 'Aktueller Plan';
        freePlan = 'Kostenlose Stufe';
        premiumPlan = 'Premium Stufe';
        usageLimits = 'Nutzungsgrenzen';
        chatUsage = 'KI-Begleiter-Chats';
        memoryUsage = 'Speicherplatz-Slots';
        upgradeBtn = 'Auf Premium upgraden (9,99 \$/Mon.)';
        cancelBtn = 'Premium-Abo kündigen';
        premiumBenefits = 'Inbegriffene Premium-Vorteile';
        b1 = 'Unbegrenzte Erinnerungen & Ziele';
        b2 = 'Werbefreies Gesamterlebnis';
        b3 = 'Priorisierte Hochgeschwindigkeits-KI';
        b4 = 'Eigene KI-Persönlichkeitsregler';
        manageBilling = 'Zahlungen verwalten';
        break;
    }

    final screenColor = isDark
        ? const Color(0xFF141318)
        : (themeState.hasMoodSelected
              ? themeState.moodTheme.background
              : AppColors.lightBackground);

    final cardColor = isDark
        ? const Color(0xFF1E1C24)
        : (themeState.hasMoodSelected
              ? themeState.moodTheme.cardColor
              : Colors.white);

    final borderColor = isDark
        ? const Color(0xFF2C2834)
        : (themeState.hasMoodSelected
              ? themeState.moodTheme.cardBorder
              : AppColors.lightCardBorder);

    return Scaffold(
      backgroundColor: screenColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Current Plan Active Badge Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: billing.isPremium
                      ? LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: billing.isPremium ? null : cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: billing.isPremium ? Colors.transparent : borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: billing.isPremium
                          ? accentColor.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlan,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: billing.isPremium
                            ? Colors.white70
                            : AppColors.secondaryText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          billing.isPremium ? premiumPlan : freePlan,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: billing.isPremium
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.text),
                          ),
                        ),
                        Icon(
                          billing.isPremium
                              ? Icons.diamond_rounded
                              : Icons.lock_open_rounded,
                          color: billing.isPremium ? Colors.white : accentColor,
                          size: 32,
                        ),
                      ],
                    ),
                    if (billing.isPremium) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Renews on: ${billing.nextBillingDate}',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. Usage limit counters
              Text(
                usageLimits,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildUsageBar(
                      title: chatUsage,
                      used: billing.chatUsed,
                      limit: billing.chatLimit,
                      isPremium: billing.isPremium,
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildUsageBar(
                      title: memoryUsage,
                      used: billing.memoryUsed,
                      limit: billing.memoryLimit,
                      isPremium: billing.isPremium,
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Premium Benefits checklist
              Text(
                premiumBenefits,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildBenefitRow(b1, accentColor, isDark),
                  _buildBenefitRow(b2, accentColor, isDark),
                  _buildBenefitRow(b3, accentColor, isDark),
                  _buildBenefitRow(b4, accentColor, isDark),
                ],
              ),

              const SizedBox(height: 36),

              // 4. Upgrade / Cancel Call to Action Button
              BouncingWidget(
                onTap: () {
                  if (billing.isPremium) {
                    ref.read(billingProvider.notifier).cancelSubscription();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Subscription Cancelled'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    ref.read(billingProvider.notifier).upgradeToPremium();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Welcome to Premium! Upgrade Successful!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: billing.isPremium
                        ? null
                        : LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.8),
                            ],
                          ),
                    color: billing.isPremium
                        ? Colors.redAccent.withValues(alpha: 0.1)
                        : null,
                    border: billing.isPremium
                        ? Border.all(color: Colors.redAccent, width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    billing.isPremium ? cancelBtn : upgradeBtn,
                    style: GoogleFonts.outfit(
                      color: billing.isPremium
                          ? Colors.redAccent
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              if (billing.isPremium) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Stripe billing portal launching... (mock)',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.payment_rounded,
                      color: accentColor,
                      size: 16,
                    ),
                    label: Text(
                      manageBilling,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageBar({
    required String title,
    required int used,
    required int limit,
    required bool isPremium,
    required Color accentColor,
    required bool isDark,
  }) {
    final double percent = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final limitStr = isPremium ? 'Unlimited' : limit.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Text(
              '$used / $limitStr',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: isDark
                ? const Color(0xFF2C2834)
                : AppColors.blueWhite,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(String text, Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_rounded, color: accentColor, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
