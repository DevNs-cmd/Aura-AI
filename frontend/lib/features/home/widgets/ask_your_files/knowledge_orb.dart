import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/aura_logo.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class KnowledgeOrb extends StatefulWidget {
  final int documentCount;
  final int selectedCount;
  final bool isAnalyzing;

  const KnowledgeOrb({
    super.key,
    required this.documentCount,
    required this.selectedCount,
    this.isAnalyzing = false,
  });

  @override
  State<KnowledgeOrb> createState() => _KnowledgeOrbState();
}

class _KnowledgeOrbState extends State<KnowledgeOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    String headingText = AppLocalizations.of(context)!.documentsOrbDefaultTitle;
    String subText = AppLocalizations.of(context)!.documentsOrbDefaultDesc;

    if (widget.documentCount == 0) {
      headingText = AppLocalizations.of(context)!.documentsOrbEmptyTitle;
      subText = AppLocalizations.of(context)!.documentsOrbEmptyDesc;
    } else if (widget.isAnalyzing) {
      headingText = AppLocalizations.of(context)!.documentsOrbAnalyzingTitle;
      subText = AppLocalizations.of(context)!.documentsOrbAnalyzingDesc;
    } else if (widget.selectedCount > 0) {
      headingText = AppLocalizations.of(context)!.documentsOrbReadyTitle;
      subText = AppLocalizations.of(
        context,
      )!.documentsOrbReadyDesc(widget.selectedCount);
    } else {
      headingText = AppLocalizations.of(context)!.documentsKnowledgeSpaceReady;
      subText = AppLocalizations.of(
        context,
      )!.documentsActiveCount(widget.documentCount);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Visual Representation of Connected Knowledge
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Connection lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OrbConnectionsPainter(color: accentColor),
                  ),
                ),

                // 2. Glowing aura spark inside breathing circle
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.1),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AuraLogo.icon(size: 32, color: accentColor),
                    ),
                  ),
                ),

                // 3. Floating mock document icons
                Positioned(
                  left: 30,
                  top: 20,
                  child: _buildFloatingIcon(
                    Icons.picture_as_pdf_rounded,
                    Colors.redAccent,
                    24,
                  ),
                ),
                Positioned(
                  right: 35,
                  top: 25,
                  child: _buildFloatingIcon(
                    Icons.description_rounded,
                    const Color(0xFF7C8CFF),
                    20,
                  ),
                ),
                Positioned(
                  left: 55,
                  bottom: 15,
                  child: _buildFloatingIcon(
                    Icons.text_snippet_rounded,
                    Colors.grey,
                    18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Titles & states description
          Text(
            headingText,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subText,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: size * 0.7),
    );
  }
}

class _OrbConnectionsPainter extends CustomPainter {
  final Color color;
  _OrbConnectionsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Connect center to float coordinate points
    final path1 = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - 30, cy - 20, 42, 34);
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx + 30, cy - 15, size.width - 47, 37);
    canvas.drawPath(path2, paint);

    final path3 = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - 15, cy + 20, 67, size.height - 27);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbConnectionsPainter oldDelegate) => false;
}
