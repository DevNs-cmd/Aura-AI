import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class OceanBackdrop extends StatefulWidget {
  final Widget child;

  const OceanBackdrop({super.key, required this.child});

  @override
  State<OceanBackdrop> createState() => _OceanBackdropState();
}

class _OceanBackdropState extends State<OceanBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate random floating particles
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _FloatingParticle(
          xPercent: _random.nextDouble(),
          yPercent: _random.nextDouble(),
          size: _random.nextDouble() * 4 + 2,
          speed: _random.nextDouble() * 0.05 + 0.02,
          opacity: _random.nextDouble() * 0.4 + 0.1,
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Custom atmospheric background painting
            Positioned.fill(
              child: CustomPaint(
                painter: _OceanAtmospherePainter(
                  animationValue: _controller.value,
                  particles: _particles,
                ),
              ),
            ),
            // Screen content
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}

class _FloatingParticle {
  double xPercent;
  double yPercent;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  _FloatingParticle({
    required this.xPercent,
    required this.yPercent,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });

  void update(double value) {
    // Drifts upwards
    yPercent -= speed * 0.005;
    if (yPercent < -0.05) {
      yPercent = 1.05;
    }
  }
}

class _OceanAtmospherePainter extends CustomPainter {
  final double animationValue;
  final List<_FloatingParticle> particles;

  _OceanAtmospherePainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Base atmospheric gradient
    final baseGradient = LinearGradient(
      colors: [
        AppColors.blueWhite,
        AppColors.iceBlue.withValues(alpha: 0.8),
        const Color(0xFFD0EFFF),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = baseGradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Large blurred ocean-blue and aqua radial shapes (soft glowing blobs)
    // Blob 1: Top-Right (Sky Blue)
    final blob1Paint = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120)
      ..style = PaintingStyle.fill;

    // Animate coordinates slowly
    final double b1x = w * 0.85 + math.sin(animationValue * math.pi * 2) * 40;
    final double b1y = h * 0.15 + math.cos(animationValue * math.pi * 2) * 30;
    canvas.drawCircle(Offset(b1x, b1y), w * 0.6, blob1Paint);

    // Blob 2: Middle-Left (Aqua Glow)
    final blob2Paint = Paint()
      ..color = AppColors.aqua.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140)
      ..style = PaintingStyle.fill;

    final double b2x =
        w * 0.1 + math.cos(animationValue * math.pi * 2 + math.pi) * 50;
    final double b2y =
        h * 0.5 + math.sin(animationValue * math.pi * 2 + math.pi) * 40;
    canvas.drawCircle(Offset(b2x, b2y), w * 0.7, blob2Paint);

    // Blob 3: Bottom (Deep Ocean Navy Glow)
    final blob3Paint = Paint()
      ..color = AppColors.oceanBlue.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 1.05), w * 0.8, blob3Paint);

    // 3. Flowing wave/ripple paths at the bottom (clean, subtle lines)
    final wavePaint = Paint()
      ..color = AppColors.oceanBlue.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final wavePath1 = Path();
    final wavePath2 = Path();

    wavePath1.moveTo(0, h * 0.9);
    wavePath2.moveTo(0, h * 0.92);

    for (double i = 0; i <= w; i += 5) {
      final double wave1 =
          math.sin((i / w * 2 * math.pi) + (animationValue * math.pi * 2)) *
              15 +
          (h * 0.88);
      final double wave2 =
          math.cos((i / w * 1.5 * math.pi) - (animationValue * math.pi * 2)) *
              12 +
          (h * 0.90);
      wavePath1.lineTo(i, wave1);
      wavePath2.lineTo(i, wave2);
    }

    canvas.drawPath(wavePath1, wavePaint);
    canvas.drawPath(
      wavePath2,
      wavePaint..color = AppColors.skyBlue.withValues(alpha: 0.05),
    );

    // 4. Subtle floating particles
    for (final particle in particles) {
      particle.update(animationValue);
      final pX = particle.xPercent * w;
      // oscillation side-to-side
      final offset =
          math.sin(animationValue * math.pi * 2 + particle.phase) * 8;
      final pY = particle.yPercent * h;

      final particlePaint = Paint()
        ..color = AppColors.skyBlue.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(pX + offset, pY), particle.size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanAtmospherePainter oldDelegate) {
    return true;
  }
}
