import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/aura_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class DocumentEmptyState extends StatelessWidget {
  final VoidCallback onAddFilesPressed;

  const DocumentEmptyState({super.key, required this.onAddFilesPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Immersive Illustrated graphic state: Aura spark surrounded by disconnected mock shapes
            SizedBox(
              height: 160,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Central aura shape
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AuraLogo.icon(size: 32, color: accentColor),
                    ),
                  ),

                  // Floating mock document blocks
                  Positioned(
                    left: 20,
                    top: 15,
                    child: _buildMockDocumentBlock(
                      Icons.picture_as_pdf_rounded,
                      Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    right: 25,
                    top: 25,
                    child: _buildMockDocumentBlock(
                      Icons.description_rounded,
                      const Color(0xFF7C8CFF).withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: 20,
                    child: _buildMockDocumentBlock(
                      Icons.text_snippet_rounded,
                      Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Typography description
            Text(
              AppLocalizations.of(context)!.documentsEmptyTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.documentsEmptyDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Action button
            PrimaryButton(
              text: AppLocalizations.of(context)!.documentsEmptyBtn,
              backgroundColor: accentColor,
              onPressed: onAddFilesPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockDocumentBlock(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
