import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class UsageChart extends StatelessWidget {
  const UsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightCardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.profileUsageInsights,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.profileUsageWeeklyChange,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileUsageWeeklyActivity,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Bar Chart Canvas Area
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _BarChartPainter()),
          ),

          const SizedBox(height: 12),
          // Days labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dayMon,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.dayTue,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.dayWed,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.dayThu,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.dayFri,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.daySat,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.daySun,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  // Height fractions for 7 days (M, T, W, T, F, S, S)
  final List<double> values = [0.32, 0.62, 0.45, 0.88, 0.58, 0.76, 0.95];

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final int count = values.length;
    final double spacing = w / (count - 1);
    final double barWidth = 14.0;

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      // Calculate centers
      final double cx = i * spacing;
      final double barHeight = values[i] * h;

      // Draw rounded vertical bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - (barWidth / 2), h - barHeight, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
