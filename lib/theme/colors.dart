import 'package:flutter/material.dart';

/// Tailwind CSS color palette mapped to Flutter colors
class AppColors {
  // Light Theme Colors
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF111827); // gray900
  static const Color darkSurface = Color(0xFF1F2937); // gray800
  static const Color darkPrimary = Color(0xFF3B82F6); // blue500
  static const Color darkSecondary = Color(0xFF60A5FA); // blue400
  static const Color darkAccent = Color(0xFF2563EB); // blue600

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // green-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  /// Returns the appropriate color based on the current theme
  static Color getSurfaceColor(bool isDark) => isDark ? darkSurface : white;
  static Color getBackgroundColor(bool isDark) =>
      isDark ? darkBackground : blue50;
  static Color getPrimaryColor(bool isDark) => isDark ? darkPrimary : blue600;
  static Color getSecondaryColor(bool isDark) =>
      isDark ? darkSecondary : blue400;
  static Color getTextColor(bool isDark) => isDark ? white : gray800;
  static Color getTextSecondaryColor(bool isDark) => isDark ? gray300 : gray600;
}
