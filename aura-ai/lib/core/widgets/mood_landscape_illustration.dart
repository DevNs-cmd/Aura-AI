import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodLandscapeIllustration extends StatelessWidget {
  final String mood;
  final double height;

  const MoodLandscapeIllustration({
    super.key,
    required this.mood,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(painter: _MoodLandscapePainter(mood: mood)),
      ),
    );
  }
}

class _MoodLandscapePainter extends CustomPainter {
  final String mood;

  _MoodLandscapePainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw background color / gradient
    final bgPaint = Paint();
    switch (mood) {
      case 'Happy':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFFFF9E6), Color(0xFFFFE0A3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'Calm':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFF2F4FF), Color(0xFFC7D2FE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'Motivated':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFF3FCF0), Color(0xFFB4F48F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'Relaxed':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFE6F9FB), Color(0xFF9EE8EF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'Reflective':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFF6F3FF), Color(0xFFC7B3FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'Focused':
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFFFF4EE), Color(0xFFFFB399)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      default:
        bgPaint.shader = const LinearGradient(
          colors: [Color(0xFFFFF9EE), Color(0xFFFFDFB8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
    }
    canvas.drawRect(rect, bgPaint);

    switch (mood) {
      case 'Happy':
        _drawHappyScene(canvas, size);
        break;
      case 'Calm':
        _drawCalmScene(canvas, size);
        break;
      case 'Motivated':
        _drawMotivatedScene(canvas, size);
        break;
      case 'Relaxed':
        _drawRelaxedScene(canvas, size);
        break;
      case 'Reflective':
        _drawReflectiveScene(canvas, size);
        break;
      case 'Focused':
        _drawFocusedScene(canvas, size);
        break;
      default:
        _drawHappyScene(canvas, size); // Fallback to friendly sun
    }
  }

  void _drawHappyScene(Canvas canvas, Size size) {
    // 1. Draw sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFEFA6).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final sunCenter = Offset(size.width * 0.75, size.height * 0.35);
    for (int i = 0; i < 8; i++) {
      final angle1 = i * (math.pi / 4);
      final angle2 = angle1 + 0.15;
      final path = Path()
        ..moveTo(sunCenter.dx, sunCenter.dy)
        ..lineTo(
          sunCenter.dx + 180 * math.cos(angle1),
          sunCenter.dy + 180 * math.sin(angle1),
        )
        ..lineTo(
          sunCenter.dx + 180 * math.cos(angle2),
          sunCenter.dy + 180 * math.sin(angle2),
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // 2. Draw rolling hills
    final hillPaint = Paint()
      ..color = const Color(0xFFF7ECE1)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.75,
        size.width * 0.65,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.94,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, hillPaint);

    final hillPaint2 = Paint()
      ..color = const Color(0xFFEFDDD0)
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.88,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path2, hillPaint2);

    // 3. Draw shining smiling sun
    final sunPaint = Paint()
      ..color = const Color(0xFFFFB84D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 30, sunPaint);

    // Cute smiley face inside the sun
    final facePaint = Paint()
      ..color = const Color(0xFF5C3A21)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(sunCenter.dx - 8, sunCenter.dy - 2),
      2.5,
      facePaint,
    );
    canvas.drawCircle(
      Offset(sunCenter.dx + 8, sunCenter.dy - 2),
      2.5,
      facePaint,
    );

    final mouthPaint = Paint()
      ..color = const Color(0xFF5C3A21)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(sunCenter.dx, sunCenter.dy + 3),
        radius: 6,
      ),
      0,
      math.pi,
      false,
      mouthPaint,
    );
  }

  void _drawCalmScene(Canvas canvas, Size size) {
    // 1. Draw falling rain drops
    final rainPaint = Paint()
      ..color = const Color(0xFF7C8CFF).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final r = math.Random(12);
    for (int i = 0; i < 15; i++) {
      final startX = r.nextDouble() * size.width;
      final startY = r.nextDouble() * size.height * 0.5 + size.height * 0.3;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 3, startY + 12),
        rainPaint,
      );
    }

    // 2. Draw soft white clouds
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final cloudCenter = Offset(size.width * 0.5, size.height * 0.4);
    canvas.drawCircle(cloudCenter, 22, cloudPaint);
    canvas.drawCircle(
      Offset(cloudCenter.dx - 22, cloudCenter.dy + 4),
      16,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cloudCenter.dx + 22, cloudCenter.dy + 4),
      16,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cloudCenter.dx - 12, cloudCenter.dy + 12),
      14,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cloudCenter.dx + 12, cloudCenter.dy + 12),
      14,
      cloudPaint,
    );

    // Cute smiley face inside the cloud
    final facePaint = Paint()
      ..color = const Color(0xFF4A4B6E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cloudCenter.dx - 6, cloudCenter.dy + 2),
      2,
      facePaint,
    );
    canvas.drawCircle(
      Offset(cloudCenter.dx + 6, cloudCenter.dy + 2),
      2,
      facePaint,
    );

    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4B6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cloudCenter.dx, cloudCenter.dy + 6),
        radius: 4,
      ),
      0,
      math.pi,
      false,
      mouthPaint,
    );
  }

  void _drawMotivatedScene(Canvas canvas, Size size) {
    // 1. Rolling green meadows
    final meadowPaint = Paint()
      ..color = const Color(0xFF99E673)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.72,
        size.width * 0.7,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.9,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, meadowPaint);

    final meadowPaint2 = Paint()
      ..color = const Color(0xFF86D75B)
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.85,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path2, meadowPaint2);

    // 2. Programmatic Pine Trees
    _drawPineTree(
      canvas,
      Offset(size.width * 0.25, size.height * 0.8),
      28,
      const Color(0xFF4B8C2B),
    );
    _drawPineTree(
      canvas,
      Offset(size.width * 0.45, size.height * 0.85),
      24,
      const Color(0xFF3B7120),
    );
    _drawPineTree(
      canvas,
      Offset(size.width * 0.75, size.height * 0.86),
      34,
      const Color(0xFF5EAA36),
    );
  }

  void _drawPineTree(
    Canvas canvas,
    Offset bottomCenter,
    double height,
    Color color,
  ) {
    final trunkWidth = height * 0.15;
    final trunkHeight = height * 0.25;

    // Draw trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF5C3D21)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        bottomCenter.dx - trunkWidth / 2,
        bottomCenter.dy - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      trunkPaint,
    );

    // Draw leafy triangles
    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final treeBaseY = bottomCenter.dy - trunkHeight + 2;
    for (int i = 0; i < 3; i++) {
      final levelHeight = height * 0.35;
      final levelWidth = trunkWidth * (4.5 - i * 1.2);
      final levelBaseY = treeBaseY - i * (levelHeight * 0.55);

      final path = Path()
        ..moveTo(bottomCenter.dx, levelBaseY - levelHeight)
        ..lineTo(bottomCenter.dx - levelWidth / 2, levelBaseY)
        ..lineTo(bottomCenter.dx + levelWidth / 2, levelBaseY)
        ..close();
      canvas.drawPath(path, leafPaint);
    }
  }

  void _drawRelaxedScene(Canvas canvas, Size size) {
    // 1. Starry dots
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      1.5,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.15),
      1.2,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.3),
      1.6,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      1.3,
      starPaint,
    );

    // 2. Rolling night hills
    final hillPaint = Paint()
      ..color = const Color(0xFF8FD8DF)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.78,
        size.width * 0.7,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.92,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, hillPaint);

    // 3. Cute crescent moon character
    final moonCenter = Offset(size.width * 0.75, size.height * 0.4);
    final moonPaint = Paint()
      ..color = const Color(0xFFFDF0A6)
      ..style = PaintingStyle.fill;

    // Draw outer circle, subtract inner circle
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: 24))
      ..addOval(
        Rect.fromCircle(
          center: Offset(moonCenter.dx - 8, moonCenter.dy - 3),
          radius: 21,
        ),
      );
    moonPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(moonPath, moonPaint);

    // Cute sleepy face on moon
    final eyePaint = Paint()
      ..color = const Color(0xFF594F3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Sleepy closed eye arch
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(moonCenter.dx + 4, moonCenter.dy - 3),
        radius: 3,
      ),
      0,
      math.pi,
      false,
      eyePaint,
    );
  }

  void _drawReflectiveScene(Canvas canvas, Size size) {
    // 1. Rain lines
    final rainPaint = Paint()
      ..color = const Color(0xFFA58BFF).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final r = math.Random(55);
    for (int i = 0; i < 18; i++) {
      final startX = r.nextDouble() * size.width;
      final startY = r.nextDouble() * size.height * 0.5 + size.height * 0.25;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 2, startY + 14),
        rainPaint,
      );
    }

    // 2. Soft lightning bolt in distance
    final boltPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final boltPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.15)
      ..lineTo(size.width * 0.26, size.height * 0.42)
      ..lineTo(size.width * 0.31, size.height * 0.38)
      ..lineTo(size.width * 0.27, size.height * 0.65);
    canvas.drawPath(boltPath, boltPaint);

    // 3. Cute purple reflective clouds
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final cloudCenter = Offset(size.width * 0.65, size.height * 0.35);
    canvas.drawCircle(cloudCenter, 18, cloudPaint);
    canvas.drawCircle(
      Offset(cloudCenter.dx - 18, cloudCenter.dy + 3),
      14,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cloudCenter.dx + 18, cloudCenter.dy + 3),
      14,
      cloudPaint,
    );
  }

  void _drawFocusedScene(Canvas canvas, Size size) {
    // Concentric light circles / focus waves
    final focusCenter = Offset(size.width * 0.75, size.height * 0.45);
    final focusPaint1 = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final focusPaint2 = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final focusPaint3 = Paint()
      ..color = const Color(0xFFFF7A45)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(focusCenter, 80, focusPaint1);
    canvas.drawCircle(focusCenter, 48, focusPaint2);
    canvas.drawCircle(focusCenter, 20, focusPaint3);

    // Draw little concentration nodes
    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(focusCenter.dx - 34, focusCenter.dy - 20),
      3,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(focusCenter.dx + 40, focusCenter.dy + 26),
      2.5,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(focusCenter.dx - 10, focusCenter.dy + 48),
      2.2,
      nodePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MoodLandscapePainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}
