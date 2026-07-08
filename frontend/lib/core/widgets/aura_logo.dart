import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum AuraLogoVariant { icon, wordmark, lockup, monochrome }

class AuraLogo extends StatelessWidget {
  final AuraLogoVariant variant;
  final double size;
  final Color? color;
  final Gradient? gradient;
  final bool animate;

  const AuraLogo({
    super.key,
    this.variant = AuraLogoVariant.lockup,
    this.size = 48.0,
    this.color,
    this.gradient,
    this.animate = false,
  });

  // Shortcut constructors
  const AuraLogo.icon({
    super.key,
    this.size = 48.0,
    this.color,
    this.gradient,
    this.animate = false,
  }) : variant = AuraLogoVariant.icon;

  const AuraLogo.wordmark({super.key, this.size = 48.0, this.color})
    : variant = AuraLogoVariant.wordmark,
      gradient = null,
      animate = false;

  const AuraLogo.lockup({
    super.key,
    this.size = 48.0,
    this.color,
    this.gradient,
    this.animate = false,
  }) : variant = AuraLogoVariant.lockup;

  const AuraLogo.monochrome({
    super.key,
    this.size = 48.0,
    this.color = Colors.white,
  }) : variant = AuraLogoVariant.monochrome,
       gradient = null,
       animate = false;

  @override
  Widget build(BuildContext context) {
    final finalGradient =
        gradient ??
        (variant == AuraLogoVariant.monochrome
            ? null
            : AppColors.oceanGradient);

    final finalColor =
        color ??
        (variant == AuraLogoVariant.monochrome
            ? Colors.white
            : AppColors.oceanBlue);

    switch (variant) {
      case AuraLogoVariant.icon:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: AuraSymbolPainter(
              color: finalColor,
              gradient: finalGradient,
            ),
          ),
        );
      case AuraLogoVariant.wordmark:
        return Text(
          'Aura AI',
          style: GoogleFonts.outfit(
            fontSize: size * 0.7,
            fontWeight: FontWeight.w900,
            color: finalColor,
            letterSpacing: -0.5,
          ),
        );
      case AuraLogoVariant.lockup:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: AuraSymbolPainter(
                  color: finalColor,
                  gradient: finalGradient,
                ),
              ),
            ),
            SizedBox(width: size * 0.25),
            Text(
              'Aura AI',
              style: GoogleFonts.outfit(
                fontSize: size * 0.65,
                fontWeight: FontWeight.w900,
                color: finalColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      case AuraLogoVariant.monochrome:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: AuraSymbolPainter(color: finalColor, gradient: null),
          ),
        );
    }
  }
}

class AuraSymbolPainter extends CustomPainter {
  final Color color;
  final Gradient? gradient;

  AuraSymbolPainter({required this.color, this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, w, h));
    } else {
      paint.color = color;
    }

    // 1. Draw central 4-pointed spark (intelligence spark)
    final sparkPath = Path();
    final double sparkRadius = radius * 0.35;

    sparkPath.moveTo(cx, cy - sparkRadius);
    sparkPath.quadraticBezierTo(cx, cy, cx + sparkRadius, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy + sparkRadius);
    sparkPath.quadraticBezierTo(cx, cy, cx - sparkRadius, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy - sparkRadius);
    sparkPath.close();
    canvas.drawPath(sparkPath, paint);

    // 2. Draw two incomplete flowing orbital curves surrounding the spark
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    if (gradient != null) {
      strokePaint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, w, h));
    } else {
      strokePaint.color = color;
    }

    // Inner orbital curve (top-left aligned, sweeping most of the way)
    final rectInner = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius * 0.62,
    );
    // starts at -160 degrees (-2.8 radians), sweeps 230 degrees (4.0 radians)
    canvas.drawArc(rectInner, -2.8, 4.0, false, strokePaint);

    // Outer orbital curve (bottom-right aligned, sweeping most of the way)
    final rectOuter = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius * 0.88,
    );
    // starts at 20 degrees (0.35 radians), sweeps 230 degrees (4.0 radians)
    canvas.drawArc(rectOuter, 0.35, 4.0, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant AuraSymbolPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gradient != gradient;
  }
}
