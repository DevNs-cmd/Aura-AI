import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/goal.dart';
import '../../../../core/theme/theme_provider.dart';

class GoalTile extends ConsumerWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback? onIncrement;
  final bool isDark;

  const GoalTile({
    super.key,
    required this.goal,
    required this.onTap,
    this.onIncrement,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accentColor;
    final tileBg = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0xFF2C2834)
        : AppColors.lightCardBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(24), // Premium soft border-radius
          border: Border.all(color: cardBorderColor, width: 1.5),
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
            // Category & Progress Percentage tag row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.category.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? Colors.white54
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: GoogleFonts.outfit(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onIncrement != null && goal.progress < 1.0) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onIncrement,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              goal.title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Progress Bar Track
            ClipRRect(
              borderRadius: BorderRadius.circular(6), // Rounded linear track
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? const Color(0xFF2C2834)
                    : AppColors.lightBackground,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 16),

            // Progress description & Calendar Date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.statusText,
                    style: GoogleFonts.quicksand(
                      color: isDark
                          ? Colors.white38
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: isDark
                          ? Colors.white30
                          : AppColors.lightTextTertiary,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      goal.deadline,
                      style: GoogleFonts.outfit(
                        color: isDark
                            ? Colors.white60
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
