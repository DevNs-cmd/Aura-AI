import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class UploadSourceSheet extends StatelessWidget {
  final Function(String source) onSourceSelected;

  const UploadSourceSheet({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2834) : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title & Subtitle
          Text(
            AppLocalizations.of(context)!.documentsSheetTitle,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.documentsSheetDesc,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Upload options grid/list
          _buildOption(
            context,
            icon: Icons.picture_as_pdf_rounded,
            title: AppLocalizations.of(context)!.documentsOptionFileTitle,
            description: AppLocalizations.of(context)!.documentsOptionFileDesc,
            color: Colors.redAccent,
            onTap: () => onSourceSelected('File'),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.cloud_queue_rounded,
            title: AppLocalizations.of(context)!.documentsOptionDriveTitle,
            description: AppLocalizations.of(context)!.documentsOptionDriveDesc,
            color: const Color(0xFF7C8CFF),
            onTap: () => onSourceSelected('Drive'),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.qr_code_scanner_rounded,
            title: AppLocalizations.of(context)!.documentsOptionCameraTitle,
            description: AppLocalizations.of(
              context,
            )!.documentsOptionCameraDesc,
            color: Colors.teal,
            onTap: () => onSourceSelected('Camera'),
          ),
          const SizedBox(height: 24),

          // File Constraints Footer Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF25232B) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C2834)
                    : AppColors.lightCardBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 18, color: accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.documentsSheetSecurityDesc,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF25232B) : const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2834) : const Color(0xFFEFEFF2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: isDark ? Colors.white30 : AppColors.lightTextTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
