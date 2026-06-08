import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color primary = Color(0xFFD4AF37);
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentHover = Color(0xFFE8C547);
  static const Color accentPressed = Color(0xFFB8860B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color disabled = Color(0xFF666666);

  /// Golden border at 50% opacity for cards and dividers.
  static const Color divider = Color(0x80D4AF37);
  static const Color cardBorder = Color(0x80D4AF37);
  static const Color warning = Color(0xFFE8C547);

  // Legacy aliases used across screens
  static const Color primaryDark = secondary;
  static const Color primaryLight = accentHover;
  static const Color accentLight = accentHover;
  static const Color teal = success;
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, accentPressed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentHover],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [secondary, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
