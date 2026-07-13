import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../billing_provider.dart';

class ChoosePlanScreen extends ConsumerWidget {
  const ChoosePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final billing = ref.watch(billingProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          loc.choosePlanTitle,
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
              Text(
                loc.choosePlanSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.choosePlanDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // 1. FREE PLAN CARD
              _buildPlanCard(
                context,
                title: loc.choosePlanFree,
                price: '₹0',
                period: loc.choosePlanPerMonth,
                description: loc.choosePlanFreeDesc,
                features: [
                  loc.choosePlanFeature50Chats,
                  loc.choosePlanFeature20Memory,
                  loc.choosePlanFeatureBasicSpeed,
                  loc.choosePlanFeatureStandardModes,
                ],
                buttonText: billing.plan == SubscriptionPlan.free ? loc.choosePlanCurrentPlan : loc.choosePlanSelectFree,
                buttonEnabled: billing.plan != SubscriptionPlan.free,
                isPopular: false,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
                onTap: () {
                  ref.read(billingProvider.notifier).cancelSubscription();
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.choosePlanSwitchedFree),
                      backgroundColor: Colors.grey,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 2. PREMIUM PLAN CARD (POPULAR)
              _buildPlanCard(
                context,
                title: loc.choosePlanPremium,
                price: '₹299',
                period: loc.choosePlanPerMonth,
                description: loc.choosePlanPremiumDesc,
                features: [
                  loc.choosePlanFeatureUnlimitedChats,
                  loc.choosePlanFeatureUnlimitedMemory,
                  loc.choosePlanFeatureHighSpeed,
                  loc.choosePlanFeatureVision,
                  loc.choosePlanFeaturePersonalities,
                ],
                buttonText: billing.plan == SubscriptionPlan.premium ? loc.choosePlanCurrentPlan : loc.choosePlanUpgradePremium,
                buttonEnabled: billing.plan != SubscriptionPlan.premium,
                isPopular: true,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
                onTap: () {
                  context.push('/purchase-summary', extra: {
                    'plan': loc.choosePlanPremium,
                    'price': 299.0,
                  });
                },
              ),

              const SizedBox(height: 24),

              // 3. PRO PLAN CARD (COMING SOON)
              _buildPlanCard(
                context,
                title: loc.choosePlanPro,
                price: '₹599',
                period: loc.choosePlanPerMonth,
                description: loc.choosePlanProDesc,
                features: [
                  loc.choosePlanFeatureAllPremium,
                  loc.choosePlanFeatureWorkspace,
                  loc.choosePlanFeatureDevApi,
                  loc.choosePlanFeaturePrioritySupport,
                ],
                buttonText: loc.choosePlanComingSoon,
                buttonEnabled: false,
                isPopular: false,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required String buttonText,
    required bool buttonEnabled,
    required bool isPopular,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPopular ? accentColor : borderColor,
          width: isPopular ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? accentColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.01),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    loc.choosePlanMostPopular,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        period,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: isPopular ? accentColor : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  BouncingWidget(
                    onTap: buttonEnabled ? onTap : () {},
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: buttonEnabled
                            ? (isPopular ? accentColor : Colors.green.withValues(alpha: 0.12))
                            : (isDark ? Colors.white10 : Colors.grey[200]),
                        border: buttonEnabled && !isPopular
                            ? Border.all(color: Colors.green, width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style: GoogleFonts.outfit(
                          color: buttonEnabled
                              ? (isPopular ? Colors.white : Colors.green)
                              : (isDark ? Colors.white30 : Colors.grey[400]),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
