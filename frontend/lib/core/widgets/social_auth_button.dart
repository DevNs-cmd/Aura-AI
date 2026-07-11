import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              24,
            ), // Capsule style from UI design
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red (Top Arc)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;
    canvas.drawArc(rect, -2.35, 1.57, false, redPaint);

    // Yellow (Left Arc)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;
    canvas.drawArc(rect, -3.92, 1.57, false, yellowPaint);

    // Green (Bottom Arc)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;
    canvas.drawArc(rect, 0.78, 2.35, false, greenPaint);

    // Blue (Right bar and arc)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;
    canvas.drawArc(rect, -0.78, 1.56, false, bluePaint);

    final blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Draw G horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - w * 0.11, r * 1.1, w * 0.22),
      blueFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
