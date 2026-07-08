import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bouncing_widget.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Gradient? gradient;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;

    final buttonWidget = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: gradient != null
          ? BoxDecoration(
              gradient: (isLoading || onPressed == null)
                  ? LinearGradient(
                      colors: gradient!.colors
                          .map((c) => c.withValues(alpha: 0.5))
                          .toList(),
                    )
                  : gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: (onPressed != null && !isLoading)
                  ? [
                      BoxShadow(
                        color: gradient!.colors.first.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            )
          : null,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient != null
              ? Colors.transparent
              : (backgroundColor ?? accentColor),
          shadowColor: gradient != null ? Colors.transparent : null,
          disabledBackgroundColor: gradient != null
              ? Colors.transparent
              : (backgroundColor ?? accentColor).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              24,
            ), // Premium rounded pill shape
          ),
          padding: EdgeInsets.zero,
          elevation: gradient != null ? 0 : null,
        ),
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
                  color: Colors.white,
                ),
              ),
      ),
    );

    if (isLoading || onPressed == null) {
      return buttonWidget;
    }

    return BouncingWidget(
      onTap: onPressed,
      child: IgnorePointer(child: buttonWidget),
    );
  }
}
