import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ocean_backdrop.dart';
import '../../../core/widgets/aura_logo.dart';
import 'animations.dart';
import 'splash_controller.dart';
import '../../auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to initialization completed event to trigger routing
    ref.listen<SplashState>(splashControllerProvider, (previous, next) {
      if (next.isInitialized) {
        final auth = ref.read(authProvider);
        context.go(auth.status == AuthStatus.authenticated ? '/home' : '/onboarding');
      }
    });

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: OceanBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Concentric aura rings and spark logo
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Ripple Concentric Aura
                              CustomPaint(
                                size: const Size(200, 200),
                                painter: _ConcentricAuraPainter(
                                  pulseValue: _pulseController.value,
                                ),
                              ),
                              // Centered logo container
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.oceanBlue.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(22),
                                child: const AuraLogo.icon(size: 48),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),

                    // Brand Typography & Tagline
                    FadeInWidget(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Aura AI',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.oceanNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInWidget(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        'Your Personal AI Companion',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: AppColors.oceanBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInWidget(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 900),
                      child: Text(
                        'Understands you. Remembers you. Grows with you.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.12),

                    // Flowing line loader instead of circular spinner
                    FadeInWidget(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 1200),
                      child: Column(
                        children: [
                          const FlowingLineLoader(width: 140, height: 3),
                          const SizedBox(height: 12),
                          Text(
                            'Connecting to your Aura...',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: AppColors.secondaryText.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConcentricAuraPainter extends CustomPainter {
  final double pulseValue;

  _ConcentricAuraPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Wave 1: Breathing Outer Glow
    final paint1 = Paint()
      ..color = AppColors.aqua.withValues(
        alpha: 0.08 + (math.sin(pulseValue * math.pi * 2) * 0.03),
      )
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, cy), 95 + (pulseValue * 15), paint1);

    // Wave 2: Concentric Thin Aura Ring
    final paint2 = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.15 - (pulseValue * 0.08))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), 65 + (pulseValue * 25), paint2);

    // Wave 3: Concentric Ring 2
    final paint3 = Paint()
      ..color = AppColors.aqua.withValues(alpha: 0.2 - (pulseValue * 0.12))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 50 + (pulseValue * 15), paint3);
  }

  @override
  bool shouldRepaint(covariant _ConcentricAuraPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}

class FlowingLineLoader extends StatefulWidget {
  final double width;
  final double height;
  const FlowingLineLoader({super.key, this.width = 120.0, this.height = 3.0});

  @override
  State<FlowingLineLoader> createState() => _FlowingLineLoaderState();
}

class _FlowingLineLoaderState extends State<FlowingLineLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: CustomPaint(painter: _LoaderLinePainter(_controller.value)),
          ),
        );
      },
    );
  }
}

class _LoaderLinePainter extends CustomPainter {
  final double progress;
  _LoaderLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.aqua,
          AppColors.skyBlue,
          Colors.transparent,
        ],
        stops: [0.0, 0.4, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Sweep drawing from left to right
    final double left = (progress * 2 - 1) * size.width;
    final double width = size.width * 0.4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, width, size.height),
        Radius.circular(size.height / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderLinePainter oldDelegate) => true;
}
