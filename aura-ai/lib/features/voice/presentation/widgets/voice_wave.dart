import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../voice_provider.dart';

class VoiceWave extends ConsumerStatefulWidget {
  final VoiceStatus status;
  const VoiceWave({super.key, required this.status});

  @override
  ConsumerState<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends ConsumerState<VoiceWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    final accentColor = themeState.accentColor;

    double speed = 1.0;
    double maxAmplitude = 24.0;

    switch (widget.status) {
      case VoiceStatus.listening:
        speed = 1.2;
        maxAmplitude = 18.0;
        break;
      case VoiceStatus.thinking:
        speed = 0.3;
        maxAmplitude = 3.0;
        break;
      case VoiceStatus.speaking:
        speed = 2.0;
        maxAmplitude = 36.0;
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: CustomPaint(
              painter: _VerticalBarWavePainter(
                progress: _controller.value,
                status: widget.status,
                speed: speed,
                maxAmplitude: maxAmplitude,
                accentColor: accentColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VerticalBarWavePainter extends CustomPainter {
  final double progress;
  final VoiceStatus status;
  final double speed;
  final double maxAmplitude;
  final Color accentColor;

  _VerticalBarWavePainter({
    required this.progress,
    required this.status,
    required this.speed,
    required this.maxAmplitude,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double midY = h / 2;

    final int barsCount = 38;
    final double barSpacing = w / (barsCount - 1);
    final double barWidth = 3.0;

    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintBg = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < barsCount; i++) {
      final double x = i * barSpacing;

      // Bell-curve envelope to fade out bars at left and right boundaries
      final double normX = i / (barsCount - 1);
      final double envelope = math.sin(
        normX * math.pi,
      ); // 0 at edges, 1 at center

      // Calculate dynamic bar height factor using sine math
      double heightFactor = 0.05;
      if (status == VoiceStatus.listening) {
        heightFactor =
            0.15 + 0.85 * math.sin(progress * 2 * math.pi + i * 0.45).abs();
      } else if (status == VoiceStatus.speaking) {
        heightFactor =
            0.2 + 0.8 * math.sin(progress * 4 * math.pi - i * 0.6).abs();
      } else if (status == VoiceStatus.thinking) {
        heightFactor =
            0.08 + 0.12 * math.sin(progress * math.pi + i * 0.2).abs();
      }

      final double barHeight = (maxAmplitude * envelope * heightFactor).clamp(
        3.0,
        h / 2 - 4,
      );

      // Draw faint background full height line for visual depth
      canvas.drawLine(
        Offset(x, midY - (h / 2 - 8) * envelope),
        Offset(x, midY + (h / 2 - 8) * envelope),
        paintBg,
      );

      // Draw active bouncing audio frequency bar
      canvas.drawLine(
        Offset(x, midY - barHeight),
        Offset(x, midY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalBarWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.maxAmplitude != maxAmplitude;
  }
}
