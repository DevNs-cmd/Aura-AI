import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor(entry.mood);
    final moodTag = _getMoodTag(context, entry.mood);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.lightTextPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.journalDetailTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextSecondary,
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
                      style: TextStyle(
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
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Body Content card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.lightCardBorder,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  entry.body,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.lightTextPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Insight card
              if (entry.aiInsight != null) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.journalAuraInsight,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.aiInsight!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
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
