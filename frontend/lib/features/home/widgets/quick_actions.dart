import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/generated/app_localizations.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class QuickActionsGrid extends ConsumerWidget {
  final ValueChanged<String>? onActionSelected;

  const QuickActionsGrid({super.key, this.onActionSelected});

  String _getLocalActionLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (label.toLowerCase()) {
      case 'voice':
        return l10n.quickActionVoice;
      case 'vision':
        return l10n.quickActionVision;
      case 'reflection':
        return l10n.quickActionReflection;
      case 'growth':
        return l10n.quickActionGrowth;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final primaryColor = themeState.accentColor;

    final List<QuickActionItem> actions = [
      QuickActionItem(
        label: 'Voice',
        icon: Icons.mic_none_rounded,
        onTap: () => onActionSelected?.call('voice'),
      ),
      QuickActionItem(
        label: 'Vision',
        icon: Icons.remove_red_eye_outlined,
        onTap: () => onActionSelected?.call('vision'),
      ),
      QuickActionItem(
        label: 'Reflection',
        icon: Icons.edit_note_rounded,
        onTap: () => onActionSelected?.call('journal'),
      ),
      QuickActionItem(
        label: 'Growth',
        icon: Icons.track_changes_rounded,
        onTap: () => onActionSelected?.call('goals'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.homeQuickActions,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.homeSeeAll,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return GestureDetector(
              onTap: action.onTap,
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2D2834)
                            : AppColors.lightCardBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(action.icon, color: primaryColor, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLocalActionLabel(context, action.label),
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white60
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
