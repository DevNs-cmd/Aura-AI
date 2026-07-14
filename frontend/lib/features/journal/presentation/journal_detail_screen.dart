import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../models/journal_entry.dart';
import '../journal_provider.dart';

class JournalDetailScreen extends ConsumerWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Great':
        return const Color(0xFF10B981);
      case 'Good':
        return AppColors.primary;
      case 'Okay':
        return const Color(0xFFF59E0B);
      case 'Sad':
        return const Color(0xFFEF4444);
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete Journal',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this journal entry? This action cannot be undone.',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(journalProvider.notifier).deleteEntry(entry.id);
                Navigator.pop(dialogContext); // Close dialog
                context.pop(); // Pop detail screen back to journal screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Journal entry deleted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final moodColor = _getMoodColor(entry.mood);
    final moodTag = _getMoodTag(context, entry.mood);

    final cardBg = isDark
        ? const Color(0xFF1E1C24)
        : (themeState.hasMoodSelected ? themeState.moodTheme.cardColor : Colors.white);

    final cardBorderColor = isDark
        ? const Color(0xFF2C2834)
        : (themeState.hasMoodSelected ? themeState.moodTheme.cardBorder : AppColors.lightCardBorder);

    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtextColor = isDark ? Colors.white60 : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected ? themeState.moodTheme.background : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.journalDetailTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, MMMM dd, yyyy',
                      Localizations.localeOf(context).toString(),
                    ).format(entry.createdAt),
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: subtextColor,
                    ),
                  ),
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                entry.title,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              // Body Content card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cardBorderColor,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  entry.body,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: textColor,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Insight card
              if (entry.aiInsight != null) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.journalAuraInsight,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.aiInsight!,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
