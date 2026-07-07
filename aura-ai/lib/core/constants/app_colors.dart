import 'package:flutter/material.dart';

class AppColors {
  // Official Design System Colors
  static const Color primary = Color(0xFFFFB84D); // Sunny yellow
  static const Color secondary = Color(0xFF7C8CFF); // Soft blue
  static const Color success = Color(0xFF7ED957); // Green
  static const Color calm = Color(0xFF57C7D4); // Minty teal
  static const Color sad = Color(0xFFA58BFF); // Purple
  static const Color background = Color(0xFFFFF7EF); // Warm light background
  static const Color surface = Color(0xFFFFFFFF); // White card background
  static const Color text = Color(0xFF1F1F1F); // Charcoal primary text

  // Custom Neutral Grays
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color lightCardBorder = Color(0xFFF6ECE2);

  // Compile-compatibility Aliases
  static const Color accentBlue = Color(0xFF7C8CFF);
  static const Color lightBackground = Color(0xFFFFF7EF);
  static const Color darkBackground = Color(0xFF141318);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1C24);
  static const Color darkCardBorder = Color(0xFF2C2834);
  static const Color lightTextPrimary = Color(0xFF1F1F1F);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextTertiary = Color(0xFF999999);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  static const Color error = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF7ED957);

  // Premium Purple Theme Colors for Welcome/Onboarding/Auth (Purple & White theme)
  static const Color purpleThemeBg = Color(
    0xFFF5F3FF,
  ); // Light warm lavender/purple
  static const Color purpleThemePrimary = Color(
    0xFF8B5CF6,
  ); // Modern rich violet/purple
  static const Color purpleThemeCardBorder = Color(0xFFE9E3FF); // Soft border
  static const LinearGradient purpleLogoGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mood colors map
  static const Color moodHappy = Color(0xFFFFB84D);
  static const Color moodCalm = Color(0xFF7C8CFF);
  static const Color moodMotivated = Color(0xFF7ED957);
  static const Color moodRelaxed = Color(0xFF57C7D4);
  static const Color moodReflective = Color(0xFFA58BFF);
  static const Color moodFocused = Color(0xFFFF7A45);
  static const Color moodTired = Color(0xFF8E9AAF);
  static const Color moodInspired = Color(0xFFFF6B6B);

  // Home Card Gradient using dynamic mood themes
  static const LinearGradient homeCardGradient = LinearGradient(
    colors: [Color(0xFFFFF9EE), Color(0xFFFFDFB8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Auth Logo Gradient
  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFFFFB84D), Color(0xFF7C8CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ocean Blue Theme Palette for Onboarding / Splash / Auth
  static const Color oceanNavy = Color(0xFF082F49);
  static const Color oceanBlue = Color(0xFF0369A1);
  static const Color clearBlue = Color(0xFF0284C7);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color aqua = Color(0xFF22D3EE);
  static const Color softCyan = Color(0xFFA5F3FC);
  static const Color iceBlue = Color(0xFFE0F2FE);
  static const Color blueWhite = Color(0xFFF0F9FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanBackdropGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
