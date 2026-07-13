import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String plan;
  final String paymentMethod;

  const PaymentProcessingScreen({
    super.key,
    required this.plan,
    required this.paymentMethod,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends ConsumerState<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    // Simulate payment transaction processing delay
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      context.go('/payment-success', extra: {
        'plan': widget.plan,
        'paymentMethod': widget.paymentMethod,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final screenColor = isDark
        ? const Color(0xFF141318)
        : (themeState.hasMoodSelected
            ? themeState.moodTheme.background
            : AppColors.lightBackground);

    return Scaffold(
      backgroundColor: screenColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                loc.paymentProcessingTitle,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.paymentProcessingSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
