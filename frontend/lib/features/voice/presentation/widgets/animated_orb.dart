import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../voice_provider.dart';

class AnimatedOrb extends ConsumerStatefulWidget {
  final VoiceStatus status;
  const AnimatedOrb({super.key, required this.status});

  @override
  ConsumerState<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends ConsumerState<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final primaryColor = themeState.hasMoodSelected
        ? themeState.moodTheme.primary
        : AppColors.purpleThemePrimary;
    final secondaryColor = themeState.hasMoodSelected
        ? themeState.moodTheme.secondary
        : const Color(0xFFDCD6F7);

    double scale = 1.0;
    double glowOpacity = 0.25;

    // Apply breathing scaling effect based on status
    switch (widget.status) {
      case VoiceStatus.listening:
        scale = 0.96 + (0.05 * math.sin(_controller.value * 2 * math.pi));
        glowOpacity = 0.35 + (0.1 * math.sin(_controller.value * 2 * math.pi));
        break;
      case VoiceStatus.thinking:
        scale = 0.98 + (0.02 * math.sin(_controller.value * 4 * math.pi));
        glowOpacity = 0.25;
        break;
      case VoiceStatus.speaking:
        scale = 1.02 + (0.08 * math.sin(_controller.value * 3 * math.pi));
        glowOpacity = 0.45 + (0.15 * math.sin(_controller.value * 3 * math.pi));
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: glowOpacity),
                  blurRadius: 40,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _SunlikeOrbPainter(
                progress: _controller.value,
                status: widget.status,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SunlikeOrbPainter extends CustomPainter {
  final double progress;
  final VoiceStatus status;
  final Color primaryColor;
  final Color secondaryColor;

  _SunlikeOrbPainter({
    required this.progress,
    required this.status,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width / 2;

    // 1. Draw outer soft concentric rings/halos
    final haloPaint = Paint()..style = PaintingStyle.fill;

    // Outer breathing ring
    final double halo1Radius =
        radius * (1.15 + 0.05 * math.sin(progress * 2 * math.pi));
    haloPaint.color = primaryColor.withValues(alpha: 0.08);
    canvas.drawCircle(Offset(cx, cy), halo1Radius, haloPaint);

    // Inner breathing ring
    final double halo2Radius =
        radius * (1.05 + 0.03 * math.cos(progress * 2 * math.pi));
    haloPaint.color = primaryColor.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(cx, cy), halo2Radius, haloPaint);

    // 2. Draw solid gradient orb
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius * 0.9);
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [secondaryColor, primaryColor],
        center: Alignment.center,
        radius: 0.8,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), radius * 0.9, orbPaint);

    // 3. Draw bright white star spark in the center
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final double centerSize = 24.0 + (3.0 * math.sin(progress * 4 * math.pi));

    // Simple 4-point star path
    starPath.moveTo(cx, cy - centerSize); // Top tip
    starPath.quadraticBezierTo(cx, cy, cx + centerSize, cy); // Top to Right
    starPath.quadraticBezierTo(cx, cy, cx, cy + centerSize); // Right to Bottom
    starPath.quadraticBezierTo(cx, cy, cx - centerSize, cy); // Bottom to Left
    starPath.quadraticBezierTo(cx, cy, cx, cy - centerSize); // Left to Top
    starPath.close();

    canvas.drawPath(starPath, starPaint);

    // Add a secondary diagonal spark ring for extra high-fidelity glow
    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), centerSize * 0.4, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _SunlikeOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
