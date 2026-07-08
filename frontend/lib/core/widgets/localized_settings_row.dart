import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedSettingsRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? trailingTextStyle;
  final bool showChevron;

  const LocalizedSettingsRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.subtitleStyle,
    this.trailingTextStyle,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultTitleStyle = GoogleFonts.outfit(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : const Color(0xFF1F1F1F),
    );

    final defaultSubtitleStyle = GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white60 : const Color(0xFF666666),
    );

    final defaultTrailingTextStyle = GoogleFonts.quicksand(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white60 : const Color(0xFF666666),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasTrailingText =
                trailingText != null && trailingText!.isNotEmpty;
            final isLongTitle = title.length > 15;
            final isLongTrailing = hasTrailingText && trailingText!.length > 15;
            final mustStack =
                constraints.maxWidth < 300 || (isLongTitle && isLongTrailing);

            Widget titleArea;
            if (mustStack) {
              titleArea = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: titleStyle ?? defaultTitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: subtitleStyle ?? defaultSubtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hasTrailingText) ...[
                    const SizedBox(height: 2),
                    Text(
                      trailingText!,
                      style: trailingTextStyle ?? defaultTrailingTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            } else {
              titleArea = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: titleStyle ?? defaultTitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: subtitleStyle ?? defaultSubtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(child: titleArea),
                if (!mustStack && (hasTrailingText || trailing != null)) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child:
                        trailing ??
                        Text(
                          trailingText!,
                          style: trailingTextStyle ?? defaultTrailingTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                  ),
                ],
                if (showChevron) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: isDark ? Colors.white30 : const Color(0xFF9E9E9E),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
