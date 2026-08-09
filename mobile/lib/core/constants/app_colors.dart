// Defines the shared color palette and semantic color helpers.

import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF81C784);

  // Status indicators
  static const Color healthy = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Card backgrounds
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);

  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return healthy;
    if (confidence >= 0.5) return warning;
    return error;
  }
}
