import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/generated/app_localizations.dart';

class GoalProgressCard extends ConsumerWidget {
  final VoidCallback? onSeeAll;
  const GoalProgressCard({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final primaryColor = themeState.accentColor;

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.homeGrowingTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.homeSeeAll,
                style: GoogleFonts.outfit(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
            borderRadius: BorderRadius.circular(
              28,
            ), // Large soft rounded corner
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2D2834)
                  : AppColors.lightCardBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalItem(
                context,
                isDark,
                title: l10n.mockGoalSessionTitle,
                subtitle: l10n.mockGoalSessionSub,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  color: isDark
                      ? const Color(0xFF2D2834)
                      : AppColors.lightCardBorder,
                  height: 1.5,
                ),
              ),
              _buildGoalItem(
                context,
                isDark,
                title: l10n.mockGoalReadingTitle,
                subtitle: l10n.mockGoalReadingSub,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
