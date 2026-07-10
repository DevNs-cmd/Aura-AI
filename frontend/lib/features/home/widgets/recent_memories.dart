import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/generated/app_localizations.dart';

class MemoryUiItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const MemoryUiItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class RecentMemoriesList extends ConsumerWidget {
  final VoidCallback? onSeeAll;
  const RecentMemoriesList({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final primaryColor = themeState.accentColor;
    final l10n = AppLocalizations.of(context)!;

    final List<MemoryUiItem> items = [
      MemoryUiItem(
        title: l10n.mockMemoryPrefTitle,
        subtitle: l10n.mockMemoryPrefTime,
        icon: Icons.settings_outlined,
      ),
      MemoryUiItem(
        title: l10n.mockMemoryInsightTitle,
        subtitle: l10n.mockMemoryInsightTime,
        icon: Icons.lightbulb_outline_rounded,
      ),
      MemoryUiItem(
        title: l10n.mockMemoryFactTitle,
        subtitle: l10n.mockMemoryFactTime,
        icon: Icons.calendar_today_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.homeRememberTitle,
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                borderRadius: BorderRadius.circular(
                  24,
                ), // Premium soft card border radius
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2D2834)
                      : AppColors.lightCardBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white60
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark
                        ? Colors.white30
                        : AppColors.lightTextTertiary,
                    size: 14,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
