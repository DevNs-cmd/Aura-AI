import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class AuraDocumentCard extends StatelessWidget {
  final String name;
  final String size;
  final String type;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onAskAura;

  const AuraDocumentCard({
    super.key,
    required this.name,
    required this.size,
    required this.type,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onAskAura,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    Color fileColor = Colors.grey;
    IconData fileIcon = Icons.text_snippet_rounded;

    if (type.toUpperCase() == 'PDF') {
      fileColor = Colors.redAccent;
      fileIcon = Icons.picture_as_pdf_rounded;
    } else if (type.toUpperCase() == 'DOC' || type.toUpperCase() == 'DOCX') {
      fileColor = const Color(0xFF7C8CFF);
      fileIcon = Icons.description_rounded;
    } else if (type.toUpperCase() == 'TXT') {
      fileColor = Colors.amber;
      fileIcon = Icons.notes_rounded;
    }

    return BouncingWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C24) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark
                      ? const Color(0xFF2C2834)
                      : AppColors.lightCardBorder),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: fileColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(fileIcon, color: fileColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Metadata text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.documentsOcrReady(size, type),
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // trailing state checkmark or popup menu
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? Colors.white30 : AppColors.lightTextTertiary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                onSelected: (val) {
                  if (val == 'delete' && onDelete != null) {
                    onDelete!();
                  } else if (val == 'ask' && onAskAura != null) {
                    onAskAura!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'ask',
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.documentsMenuAsk,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.documentsMenuPreview,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.documentsMenuDelete,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
