import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class PersonalitySelector extends ConsumerWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PersonalitySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<String> _options = const [
    'Empathetic',
    'Analytical',
    'Witty',
    'Concise',
    'Creative',
  ];

  String _getLocalOptionLabel(BuildContext context, String opt) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return opt;
    switch (opt) {
      case 'Empathetic':
        return l10n.personalityEmpathetic;
      case 'Analytical':
        return l10n.personalityAnalytical;
      case 'Witty':
        return l10n.personalityWitty;
      case 'Concise':
        return l10n.personalityConcise;
      case 'Creative':
        return l10n.personalityCreative;
      default:
        return opt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final primaryColor = themeState.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(28), // Large soft border radius
        border: Border.all(
          color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.personalityTitle,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.personalitySubtitle,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
              height: 1.45,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((opt) {
              final isSelected = selected == opt;
              return GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? const Color(0xFF141318) : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? const Color(0xFF2C2834)
                                : AppColors.lightCardBorder,
                            width: 1.5,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _getLocalOptionLabel(context, opt),
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? Colors.white70
                                : AppColors.lightTextPrimary),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
