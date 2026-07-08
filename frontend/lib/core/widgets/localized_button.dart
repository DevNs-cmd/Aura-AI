import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;

  const LocalizedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.gradient,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;

    final buttonContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );

    final boxDecoration = gradient != null
        ? BoxDecoration(
            gradient: (isLoading || onPressed == null)
                ? LinearGradient(
                    colors: gradient!.colors
                        .map((c) => c.withValues(alpha: 0.5))
                        .toList(),
                  )
                : gradient,
            borderRadius: BorderRadius.circular(24),
          )
        : null;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: gradient != null
          ? Colors.transparent
          : (backgroundColor ?? accentColor),
      shadowColor: gradient != null ? Colors.transparent : null,
      disabledBackgroundColor: gradient != null
          ? Colors.transparent
          : (backgroundColor ?? accentColor).withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.zero,
      elevation: gradient != null ? 0 : null,
      minimumSize: const Size(88, 48),
    );

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: boxDecoration,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: buttonStyle,
        child: buttonContent,
      ),
    );
  }
}
