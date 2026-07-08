import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A custom widget that renders a breathing, glowing orb effect using animation.
class GlowingOrb extends StatefulWidget {
  final double size;
  final Color? color;
  final Color? accentColor;
  const GlowingOrb({super.key, this.size = 180, this.color, this.accentColor});

  @override
  State<GlowingOrb> createState() => _GlowingOrbState();
}

class _GlowingOrbState extends State<GlowingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blurAnimation = Tween<double>(
      begin: 20.0,
      end: 45.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.25,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? AppColors.purpleThemePrimary;
    final accentColor = widget.accentColor ?? const Color(0xFFC084FC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentSize = widget.size * _scaleAnimation.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glowing layer (blurred radial shadow effect)
            Container(
              width: currentSize * 1.5,
              height: currentSize * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(
                      alpha: _opacityAnimation.value,
                    ),
                    blurRadius: _blurAnimation.value * 1.5,
                    spreadRadius: _blurAnimation.value * 0.4,
                  ),
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: _opacityAnimation.value * 0.6,
                    ),
                    blurRadius: _blurAnimation.value,
                    spreadRadius: _blurAnimation.value * 0.1,
                  ),
                ],
              ),
            ),
            // Inner core glowing layer
            Container(
              width: currentSize,
              height: currentSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0x80FFFFFF),
                    Color(0x1A5F5CFF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
            ),
            child ?? const SizedBox.shrink(),
          ],
        );
      },
      child: Container(
        width: widget.size * 0.7,
        height: widget.size * 0.7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.logoGradient,
        ),
      ),
    );
  }
}

/// A fade-in animation transition container for page elements.
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
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
        return Opacity(
          opacity: _opacity.value,
          child: FractionalTranslation(
            translation: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
