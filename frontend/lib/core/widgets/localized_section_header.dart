import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedSectionHeader extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;

  const LocalizedSectionHeader({
    super.key,
    required this.title,
    this.style,
    this.padding = const EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 8,
      top: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultStyle = GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white60 : const Color(0xFF666666),
      letterSpacing: 0.5,
    );

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: style ?? defaultStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
