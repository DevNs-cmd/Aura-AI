import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';

class PurchaseSummaryScreen extends ConsumerWidget {
  final String plan;
  final double price;

  const PurchaseSummaryScreen({
    super.key,
    required this.plan,
    required this.price,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
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

    // Calculations
    final tax = double.parse((price * 0.18).toStringAsFixed(2));
    final total = double.parse((price + tax).toStringAsFixed(2));

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
          loc.purchaseSummaryTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary Title
              Text(
                loc.purchaseSummaryReview,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Billing Card details
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.purchaseSummaryIncludes,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Pricing breakdown list
                    _buildPricingRow(
                      loc.purchaseSummarySubtotal,
                      '₹${price.toStringAsFixed(2)}',
                      isDark: isDark,
                      isBold: false,
                    ),
                    const SizedBox(height: 12),
                    _buildPricingRow(
                      loc.purchaseSummaryTaxGst,
                      '₹${tax.toStringAsFixed(2)}',
                      isDark: isDark,
                      isBold: false,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildPricingRow(
                      loc.purchaseSummaryTotalDue,
                      '₹${total.toStringAsFixed(2)}',
                      isDark: isDark,
                      isBold: true,
                      accentColor: accentColor,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Proceed button
              BouncingWidget(
                onTap: () {
                  context.push('/payment', extra: {
                    'plan': plan,
                    'price': price,
                  });
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    loc.purchaseSummaryProceed,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  loc.purchaseSummaryCancelNote,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white30 : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingRow(
    String label,
    String value, {
    required bool isDark,
    required bool isBold,
    Color? accentColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                )
              : GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                ),
        ),
        Text(
          value,
          style: isBold
              ? GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accentColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary),
                )
              : GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                ),
        ),
      ],
    );
  }
}
