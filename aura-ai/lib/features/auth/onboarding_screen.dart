import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ocean_backdrop.dart';
import '../../../core/widgets/aura_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../splash/presentation/animations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: OceanBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.oceanBlue,
                          size: 20,
                        ),
                        onPressed: () {
                          _pageController.animateToPage(
                            _currentPage - 1,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                      )
                    else
                      const SizedBox(width: 48),
                    if (_currentPage < 3)
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.outfit(
                            color: AppColors.oceanBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildPage1(screenSize),
                    _buildPage2(screenSize),
                    _buildPage3(screenSize),
                    _buildPage4(screenSize),
                  ],
                ),
              ),

              // Bottom control elements
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // Refined indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.clearBlue
                                : AppColors.skyBlue.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Primary action button
                    PrimaryButton(
                      text: _currentPage == 3 ? 'Let\'s Begin' : 'Continue',
                      onPressed: _nextPage,
                      gradient: AppColors.oceanGradient,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 1: Personal Companion Orbit
  Widget _buildPage1(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          // Visual Illustration
          SizedBox(
            height: 260,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Orbit lines painter
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: _OrbitLinesPainter(
                        animationValue: _animationController.value,
                      ),
                    ),
                    // Centered aura logo spark
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const AuraLogo.icon(size: 32),
                    ),
                    // Floating context card 1: Chat/Conversation
                    _buildOrbitingCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Talk',
                      angle: _animationController.value * 2 * math.pi,
                      radius: 95,
                    ),
                    // Floating context card 2: Memory
                    _buildOrbitingCard(
                      icon: Icons.psychology_outlined,
                      label: 'Memory',
                      angle:
                          (_animationController.value * 2 * math.pi) +
                          (math.pi * 0.5),
                      radius: 95,
                    ),
                    // Floating context card 3: Goals
                    _buildOrbitingCard(
                      icon: Icons.emoji_events_outlined,
                      label: 'Goals',
                      angle:
                          (_animationController.value * 2 * math.pi) + math.pi,
                      radius: 95,
                    ),
                    // Floating context card 4: Journal
                    _buildOrbitingCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Reflect',
                      angle:
                          (_animationController.value * 2 * math.pi) +
                          (math.pi * 1.5),
                      radius: 95,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'An AI Companion That Knows You',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.oceanNavy,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Supporting Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Aura learns from your conversations and grows more helpful over time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 2: Long-Term Memory Constellation
  Widget _buildPage2(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          // Visual Illustration (Connected Node Network)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 260),
                  painter: _ConstellationPainter(
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Your Journey, Remembered',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.oceanNavy,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Supporting Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Aura remembers important moments, preferences, and context that matter to you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 3: Intelligent Conversations dialogs
  Widget _buildPage3(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          // Visual Illustration (Floating Dialogue Bubbles)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Soft Ring
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skyBlue.withValues(alpha: 0.06),
                  ),
                ),
                // Center Spark Icon
                const Positioned(
                  bottom: 24,
                  left: 48,
                  child: AuraLogo.icon(size: 44),
                ),
                // Bubble 1 (Left aligned AI bubble)
                Positioned(
                  top: 20,
                  left: 32,
                  child: FadeInWidget(
                    duration: const Duration(milliseconds: 800),
                    child: _buildChatOnboardBubble(
                      text: "Hi! How can I support your day today?",
                      isUser: false,
                    ),
                  ),
                ),
                // Bubble 2 (Right aligned user bubble)
                Positioned(
                  top: 85,
                  right: 32,
                  child: FadeInWidget(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                    child: _buildChatOnboardBubble(
                      text: "Remind me to finish reading my book.",
                      isUser: true,
                    ),
                  ),
                ),
                // Bubble 3 (Left aligned response bubble)
                Positioned(
                  top: 150,
                  left: 40,
                  child: FadeInWidget(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 800),
                    child: _buildChatOnboardBubble(
                      text: "Sure! Stored in memories. Let's make time.",
                      isUser: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Conversations With Context',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.oceanNavy,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Supporting Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Talk naturally. Aura uses what it knows about you to provide more personal responses.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 4: Ready Screen
  Widget _buildPage4(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          // Visual Illustration (Large Spark + Expanding Wave Ripple)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric ripple painter
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _RippleWavePainter(
                        animationValue: _animationController.value,
                      ),
                    ),
                    // Centered Large Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.oceanBlue.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: const AuraLogo.icon(size: 56),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Your Aura Is Ready',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.oceanNavy,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Supporting Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Start building a companion that understands you better every day.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers for orbiting widgets
  Widget _buildOrbitingCard({
    required IconData icon,
    required String label,
    required double angle,
    required double radius,
  }) {
    final double dx = radius * math.cos(angle);
    final double dy = radius * math.sin(angle);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.skyBlue.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.oceanBlue),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.oceanNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chat bubbles helper
  Widget _buildChatOnboardBubble({required String text, required bool isUser}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.clearBlue : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(20),
        ),
        border: Border.all(
          color: isUser
              ? Colors.transparent
              : AppColors.skyBlue.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          color: isUser ? Colors.white : AppColors.darkText,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OrbitLinesPainter extends CustomPainter {
  final double animationValue;
  _OrbitLinesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final paint = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy), 95, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitLinesPainter oldDelegate) => false;
}

class _ConstellationPainter extends CustomPainter {
  final double animationValue;

  _ConstellationPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Node locations
    final points = [
      Offset(w * 0.5, h * 0.5), // Center Node
      Offset(w * 0.2, h * 0.35), // Left High
      Offset(w * 0.35, h * 0.75), // Left Low
      Offset(w * 0.8, h * 0.38), // Right High
      Offset(w * 0.65, h * 0.78), // Right Low
      Offset(w * 0.15, h * 0.68), // Extreme Left Low
      Offset(w * 0.85, h * 0.65), // Extreme Right Low
    ];

    final paintLine = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // 1. Draw connections
    canvas.drawLine(points[0], points[1], paintLine);
    canvas.drawLine(points[0], points[2], paintLine);
    canvas.drawLine(points[0], points[3], paintLine);
    canvas.drawLine(points[0], points[4], paintLine);
    canvas.drawLine(points[1], points[5], paintLine);
    canvas.drawLine(points[2], points[5], paintLine);
    canvas.drawLine(points[3], points[6], paintLine);
    canvas.drawLine(points[4], points[6], paintLine);

    // 2. Draw nodes
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final double phaseShift = i * 1.5;
      final double breath = math.sin(
        (animationValue * math.pi * 2) + phaseShift,
      );
      final double radius = 8 + (breath * 2);

      // Outer Glow
      final glowPaint = Paint()
        ..color = AppColors.aqua.withValues(alpha: 0.15 + (breath * 0.05))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(p, radius + 8, glowPaint);

      // Inner Node Circle
      final nodePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, radius, nodePaint);

      final borderPaint = Paint()
        ..color = AppColors.oceanBlue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(p, radius, borderPaint);

      // Spark symbol on center node
      if (i == 0) {
        final sparkPaint = Paint()
          ..color = AppColors.clearBlue
          ..style = PaintingStyle.fill;
        final sparkPath = Path();
        sparkPath.moveTo(p.dx, p.dy - 5);
        sparkPath.quadraticBezierTo(p.dx, p.dy, p.dx + 5, p.dy);
        sparkPath.quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + 5);
        sparkPath.quadraticBezierTo(p.dx, p.dy, p.dx - 5, p.dy);
        sparkPath.quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - 5);
        sparkPath.close();
        canvas.drawPath(sparkPath, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}

class _RippleWavePainter extends CustomPainter {
  final double animationValue;

  _RippleWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    for (int i = 0; i < 3; i++) {
      final double startPhase = (animationValue + (i * 0.33)) % 1.0;
      final double radius = 50 + (startPhase * 80);
      final double opacity = (1.0 - startPhase).clamp(0.0, 1.0) * 0.25;

      final paint = Paint()
        ..color = AppColors.aqua.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RippleWavePainter oldDelegate) => true;
}
