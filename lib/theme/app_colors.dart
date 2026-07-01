// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core neon green — this is your brand color, use it for primary actions,
  // active states, highlights
  static const Color neonGreen = Color(0xFF9EFF6B); // matches image 1's acid green
  static const Color neonGreenDim = Color(0xFF6FCB4A); // for secondary emphasis

  // Backgrounds
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF1C1C1E); // your existing card color
  static const Color surfaceHigh = Color(0xFF262628); // slightly raised cards
  static const Color divider = Color(0xFF2C2C2E);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  // Stat tile accents — instead of random colors, use green at different
  // opacities/tints so tiles feel like a family, not a rainbow
  static const Color statAccent1 = neonGreen;
  static const Color statAccent2 = Color(0xFFC6FF6B); // yellow-green
  static const Color statAccent3 = Color(0xFF6BFFC0); // teal-green
  static const Color statAccent4 = Color(0xFF6BFF9E); // mint-green
}