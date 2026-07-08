import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class AskFilesBar extends StatelessWidget {
  final int selectedCount;
  final bool hasDocuments;
  final VoidCallback onUploadPressed;
  final Function(String)? onSubmit;

  const AskFilesBar({
    super.key,
    required this.selectedCount,
    required this.hasDocuments,
    required this.onUploadPressed,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Context tag / attachment icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selectedCount > 0
                      ? Icons.check_circle_rounded
                      : Icons.all_inclusive_rounded,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  selectedCount > 0
                      ? AppLocalizations.of(
                          context,
                        )!.documentsSelectedCount(selectedCount)
                      : AppLocalizations.of(context)!.documentsAllFiles,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Text Field
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.documentsAskHint,
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                if (!hasDocuments) {
                  // Direct explanation if empty
                  FocusScope.of(context).unfocus();
                  _showNoDocsExplanation(context);
                }
              },
            ),
          ),

          // Send / Action button
          IconButton(
            onPressed: () {
              if (!hasDocuments) {
                _showNoDocsExplanation(context);
              } else if (controller.text.trim().isNotEmpty &&
                  onSubmit != null) {
                onSubmit!(controller.text.trim());
                controller.clear();
              }
            },
            icon: Icon(
              Icons.send_rounded,
              color: hasDocuments ? accentColor : AppColors.secondaryText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showNoDocsExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Text(
            AppLocalizations.of(context)!.documentsAlertUploadFirstTitle,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.documentsAlertUploadFirstDesc,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.documentsSheetCancel,
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onUploadPressed();
              },
              child: Text(
                AppLocalizations.of(context)!.documentsAlertUploadFirstBtn,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
