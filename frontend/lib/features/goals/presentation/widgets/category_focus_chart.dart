import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

class CategoryFocusChart extends StatelessWidget {
  const CategoryFocusChart({super.key});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Category Focus',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Row containing chart and labels
          Row(
            children: [
              // Donut Chart Canvas Area
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(painter: _DonutChartPainter()),
              ),
              const SizedBox(width: 32),

              // Legend Labels Column
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      label: 'Work',
                      value: '45%',
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    _LegendItem(
                      label: 'Health',
                      value: '35%',
                      color: AppColors.accentBlue,
                    ),
                    SizedBox(height: 12),
                    _LegendItem(
                      label: 'Learning',
                      value: '20%',
                      color: Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.42;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.square;

    // Work: 45% (360 * 0.45 = 162 deg)
    paint.color = AppColors.primary;
    canvas.drawArc(rect, -math.pi / 2, 162 * math.pi / 180, false, paint);

    // Health: 35% (360 * 0.35 = 126 deg)
    paint.color = AppColors.accentBlue;
    canvas.drawArc(
      rect,
      (-math.pi / 2) + (162 * math.pi / 180),
      126 * math.pi / 180,
      false,
      paint,
    );

    // Learning: 20% (360 * 0.20 = 72 deg)
    paint.color = const Color(0xFF8B5CF6);
    canvas.drawArc(
      rect,
      (-math.pi / 2) + (288 * math.pi / 180),
      72 * math.pi / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
