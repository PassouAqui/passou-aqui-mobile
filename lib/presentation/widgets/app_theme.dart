import 'package:flutter/material.dart';
import '../../di.dart';
import '../../theme/light_theme.dart';
import '../../theme/dark_theme.dart';

/// AppTheme widget that manages the application's theme based on user preferences
class AppTheme extends StatelessWidget {
  final Widget child;

  const AppTheme({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = getUserPreferencesProvider();

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final preferences = provider.preferences;
        if (preferences == null) {
          return Theme(
            data: LightTheme.theme,
            child: child,
          );
        }

        final isDarkMode = preferences.darkMode;
        final isHighContrast = preferences.highContrast;

        // Get the base theme based on dark mode
        final baseTheme = isDarkMode ? DarkTheme.theme : LightTheme.theme;

        // Apply high contrast adjustments if needed
        final theme = isHighContrast
            ? _applyHighContrast(baseTheme, isDarkMode)
            : baseTheme;

        // Apply font size adjustments
        final themeWithFontSize = theme.copyWith(
          textTheme: _applyFontSize(theme.textTheme, preferences.fontSize),
        );

        return Theme(
          data: themeWithFontSize,
          child: child,
        );
      },
    );
  }

  /// Applies high contrast adjustments to the theme
  ThemeData _applyHighContrast(ThemeData baseTheme, bool isDarkMode) {
    final highContrastColors = isDarkMode
        ? {
            'primary': Colors.white,
            'onPrimary': Colors.black,
            'surface': Colors.black,
            'onSurface': Colors.white,
            'background': Colors.black,
            'onBackground': Colors.white,
          }
        : {
            'primary': Colors.black,
            'onPrimary': Colors.white,
            'surface': Colors.white,
            'onSurface': Colors.black,
            'background': Colors.white,
            'onBackground': Colors.black,
          };

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: highContrastColors['primary']!,
        onPrimary: highContrastColors['onPrimary']!,
        surface: highContrastColors['surface']!,
        onSurface: highContrastColors['onSurface']!,
        surfaceContainerLowest: highContrastColors['background']!,
      ),
      iconTheme: IconThemeData(
        color: highContrastColors['onSurface'],
      ),
      cardTheme: CardThemeData(
        color: highContrastColors['surface'],
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: highContrastColors['onPrimary'],
          backgroundColor: highContrastColors['primary'],
          elevation: 2,
        ),
      ),
    );
  }

  /// Applies font size adjustments to the text theme
  TextTheme _applyFontSize(TextTheme baseTheme, String fontSize) {
    final factor = _getFontSizeFactor(fontSize);

    return TextTheme(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: 57 * factor),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: 45 * factor),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: 36 * factor),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: 32 * factor),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: 28 * factor),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: 24 * factor),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: 22 * factor),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: 16 * factor),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: 14 * factor),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: 16 * factor),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: 14 * factor),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: 12 * factor),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: 14 * factor),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: 12 * factor),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: 11 * factor),
    );
  }

  double _getFontSizeFactor(String fontSize) {
    switch (fontSize) {
      case 'small':
        return 0.8;
      case 'large':
        return 1.2;
      case 'medium':
      default:
        return 1.0;
    }
  }
}
