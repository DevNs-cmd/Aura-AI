import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../models/journal_entry.dart';

class JournalCard extends ConsumerWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onInsightTap;

  const JournalCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onInsightTap,
  });

  Color _getMoodColor(String mood, Color accentColor) {
    switch (mood) {
      case 'Great':
        return AppColors.success;
      case 'Good':
        return accentColor;
      case 'Okay':
        return const Color(0xFF57C7D4);
      case 'Sad':
        return const Color(0xFFA58BFF);
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String _getMoodTag(BuildContext context, String mood) {
    final l10n = AppLocalizations.of(context)!;
    switch (mood) {
      case 'Great':
        return l10n.moodTagPeaceful;
      case 'Good':
        return l10n.moodTagProductive;
      case 'Okay':
        return l10n.moodTagReflective;
      case 'Sad':
        return l10n.moodTagHeavy;
      default:
        return l10n.moodTagReflective;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final moodColor = _getMoodColor(entry.mood, accentColor);
    final moodTag = _getMoodTag(context, entry.mood);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C24) : Colors.white,
          borderRadius: BorderRadius.circular(24), // Premium soft border radius
          border: Border.all(
            color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Date and Mood Tag row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      'MMMM dd, yyyy',
                      Localizations.localeOf(context).toString(),
                    ).format(entry.createdAt),
                    style: GoogleFonts.quicksand(
                      color: isDark
                          ? Colors.white38
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: moodColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moodTag,
                    style: GoogleFonts.outfit(
                      color: moodColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              entry.title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Body Snippet
            Text(
              entry.body,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // AI Insight link at bottom
            if (entry.aiInsight != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onInsightTap ?? onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: accentColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.journalCardAiInsight,
                      style: GoogleFonts.outfit(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
