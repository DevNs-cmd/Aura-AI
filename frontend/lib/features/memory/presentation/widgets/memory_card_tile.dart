import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../models/memory.dart';

class MemoryCardTile extends ConsumerWidget {
  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;
  final VoidCallback onDelete;

  const MemoryCardTile({
    super.key,
    required this.memory,
    required this.onTap,
    required this.onPinToggle,
    required this.onDelete,
  });

  IconData _getCategoryIcon(MemoryCategory cat) {
    switch (cat) {
      case MemoryCategory.personal:
        return Icons.person_outline_rounded;
      case MemoryCategory.work:
        return Icons.work_outline_rounded;
      case MemoryCategory.insight:
        return Icons.auto_awesome_rounded;
      case MemoryCategory.fact:
        return Icons.notes_rounded;
    }
  }

  Color _getCategoryColor(MemoryCategory cat, Color accentColor) {
    switch (cat) {
      case MemoryCategory.personal:
        return accentColor;
      case MemoryCategory.work:
        return const Color(0xFF7C8CFF);
      case MemoryCategory.insight:
        return const Color(0xFF57C7D4);
      default:
        return const Color(0xFFA58BFF);
    }
  }

  String _getCategoryName(MemoryCategory cat) {
    switch (cat) {
      case MemoryCategory.personal:
        return 'Personal';
      case MemoryCategory.work:
        return 'Work';
      case MemoryCategory.insight:
        return 'Insight';
      case MemoryCategory.fact:
        return 'Fact';
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      return 'Remembered today';
    } else if (diff.inDays == 1) {
      return 'Remembered yesterday';
    } else if (diff.inDays < 7) {
      return 'Remembered ${diff.inDays} days ago';
    } else {
      return 'Remembered ${DateFormat('MMM d').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final catColor = _getCategoryColor(memory.category, accentColor);
    final catIcon = _getCategoryIcon(memory.category);
    final timeStr = _getTimeAgo(memory.storedAt);

    final Color bgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final Color borderColor = isDark
        ? const Color(0xFF2C2834)
        : AppColors.lightCardBorder;
    final Color textPrimary = isDark
        ? Colors.white
        : AppColors.lightTextPrimary;
    final Color textSecondary = isDark
        ? Colors.white70
        : AppColors.lightTextSecondary;
    final Color textTertiary = isDark
        ? Colors.white30
        : AppColors.lightTextTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // Consistent rounded corners
          border: Border.all(color: borderColor, width: 1.5),
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
            // Header Row: Category avatar + title & details, plus importance tags
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon avatar circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 18),
                ),
                const SizedBox(width: 14),

                // Title & Date block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: GoogleFonts.quicksand(
                          color: textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Importance Tag row & pin icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A45).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'high',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF7A45),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        memory.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        color: memory.isPinned ? accentColor : textTertiary,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onPinToggle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Body content description text
            Text(
              memory.description,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Footer Category Label tag
            Row(
              children: [
                Icon(catIcon, color: textSecondary, size: 13),
                const SizedBox(width: 6),
                Text(
                  _getCategoryName(memory.category),
                  style: GoogleFonts.outfit(
                    color: textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
