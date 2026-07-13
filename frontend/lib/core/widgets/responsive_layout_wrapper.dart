import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool usePhoneFrame;

  const ResponsiveLayoutWrapper({
    super.key,
    required this.child,
    this.usePhoneFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isDesktop = screenWidth > 600;

    if (!isDesktop || !usePhoneFrame) {
      return child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F13)
          : const Color(0xFFEEF2F6),
      body: Center(
        child: Container(
          width: 460,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF26262B) : const Color(0xFFE2E8F0),
              width: 4,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
