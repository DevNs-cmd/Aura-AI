import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedActionRow extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final TextStyle? titleStyle;
  final TextStyle? actionStyle;

  const LocalizedActionRow({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onActionPressed,
    this.titleStyle,
    this.actionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultTitleStyle = GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : const Color(0xFF1F1F1F),
    );

    final defaultActionStyle = GoogleFonts.quicksand(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: theme.primaryColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final titleWidthEstimate = title.length * 9.0;
        final actionWidthEstimate = actionLabel.length * 8.0;
        final totalEstimated = titleWidthEstimate + actionWidthEstimate + 24.0;

        if (constraints.maxWidth < totalEstimated) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: titleStyle ?? defaultTitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onActionPressed,
                child: Text(
                  actionLabel,
                  style: actionStyle ?? defaultActionStyle,
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? defaultTitleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onActionPressed,
              child: Text(
                actionLabel,
                style: actionStyle ?? defaultActionStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}
