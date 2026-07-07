import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedMetadataRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const LocalizedMetadataRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultLabelStyle = GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white60 : const Color(0xFF666666),
    );

    final defaultValueStyle = GoogleFonts.outfit(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white70 : const Color(0xFF1F1F1F),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalLength = label.length + value.length;
        if (constraints.maxWidth < 200 || totalLength > 30) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: labelStyle ?? defaultLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ?? defaultValueStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: labelStyle ?? defaultLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: valueStyle ?? defaultValueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }
}
