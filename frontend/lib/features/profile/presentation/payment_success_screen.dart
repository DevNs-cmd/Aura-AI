import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../billing_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String plan;

  const PaymentSuccessScreen({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();

    // Trigger state change immediately on entering success state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isProPlan = widget.plan.toLowerCase().contains('pro');
      ref.read(billingProvider.notifier).changePlan(
            isProPlan ? SubscriptionPlan.pro : SubscriptionPlan.premium,
          );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    final cardColor = isDark
        ? const Color(0xFF1E1C24)
        : (themeState.hasMoodSelected
            ? themeState.moodTheme.cardColor
            : Colors.white);

    final isProPlan = widget.plan.toLowerCase().contains('pro');

    return Scaffold(
      backgroundColor: screenColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Crown/Trophy check icon
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isProPlan ? Colors.purple.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isProPlan ? Colors.purple : Colors.amber,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isProPlan ? Icons.workspace_premium_rounded : Icons.diamond_rounded,
                      color: isProPlan ? Colors.purple : Colors.amber,
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Text(
                loc.paymentSuccessWelcome,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.paymentSuccessMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 36),

              // Summary list of unlocked benefits
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSuccessRow(Icons.bolt_rounded, loc.paymentSuccessFeatureSpeed, accentColor),
                    const SizedBox(height: 12),
                    _buildSuccessRow(Icons.all_inclusive_rounded, loc.paymentSuccessFeatureChats, accentColor),
                    const SizedBox(height: 12),
                    _buildSuccessRow(Icons.psychology_rounded, loc.paymentSuccessFeatureMemory, accentColor),
                    const SizedBox(height: 12),
                    _buildSuccessRow(Icons.remove_red_eye_rounded, loc.paymentSuccessFeatureVision, accentColor),
                  ],
                ),
              ),

              const Spacer(),

              // Go to Dashboard
              BouncingWidget(
                onTap: () {
                  context.go('/billing');
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
                    loc.paymentSuccessGoToDashboard,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(IconData icon, String text, Color accentColor) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
