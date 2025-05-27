import 'package:flutter/material.dart';

/// Spacing system following Material Design guidelines
class Spacing {
  // Base spacing unit (4dp)
  static const double unit = 4.0;

  // Spacing values
  static const double xs = unit; // 4dp
  static const double sm = unit * 2; // 8dp
  static const double md = unit * 4; // 16dp
  static const double lg = unit * 6; // 24dp
  static const double xl = unit * 8; // 32dp
  static const double xxl = unit * 12; // 48dp
  static const double xxxl = unit * 16; // 64dp

  // Component-specific spacing
  static const double buttonPadding = md;
  static const double cardPadding = 16.0;
  static const double dialogPadding = 24.0;
  static const double inputPadding = sm;
  static const double inputPaddingHorizontal = 12.0;
  static const double inputPaddingVertical = 8.0;
  static const double listItemPadding = md;
  static const double screenPadding = md;
  static const double iconPadding = xs;
  static const double dividerSpacing = md;
  static const double bottomSheetPadding = 24.0;

  // Layout-specific spacing
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const double fabMargin = 16.0;
  static const double drawerWidth = 304.0;
  static const double modalBottomSheetPadding = 24.0;
  static const double snackBarHeight = 48.0;
  static const double tooltipSpacing = 8.0;

  // Border radius values
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  static const double radiusCircular = 999.0;

  // Elevation values (in dp)
  static const double elevationNone = 0.0;
  static const double elevationXs = 2.0;
  static const double elevationSm = 4.0;
  static const double elevationMd = 8.0;
  static const double elevationLg = 12.0;
  static const double elevationXl = 16.0;

  // Animation durations (in milliseconds)
  static const int durationXs = 100;
  static const int durationSm = 200;
  static const int durationMd = 300;
  static const int durationLg = 400;
  static const int durationXl = 500;

  // Animation curves
  static const curveDefault = Curves.easeInOut;
  static const curveAccelerate = Curves.easeIn;
  static const curveDecelerate = Curves.easeOut;
  static const curveSharp = Curves.easeInOutCubic;

  /// Navigation-specific spacing
  static const double navigationRailPadding = 12.0;
  static const double navigationDrawerPadding = 16.0;
}
