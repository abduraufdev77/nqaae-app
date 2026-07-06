import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF2D86CA);
  static const Color primaryLight = Color(0xFF63B6F2);
  static const Color primaryDark = Color(0xFF145C95);
  static const Color accent = Color(0xFF39A38D);
  static const Color accentDark = Color(0xFF167463);
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accent],
  );

  // Dark theme backgrounds
  static const Color darkBg = Color(0xFF071822);
  static const Color darkSurface = Color(0xFF0B2631);
  static const Color darkCard = Color(0x661B3A45);
  static const Color darkBorder = Color(0x4039A38D);

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1735), Color(0xFF064644)],
  );

  // Light theme backgrounds
  static const Color lightBg = Color(0xFF071822);
  static const Color lightSurface = Color(0xFF0B2631);
  static const Color lightCard = Color(0x6621454F);
  static const Color lightBorder = Color(0x3339A38D);

  // Glass effect
  static const Color glassDark = Color(0x1FFFFFFF);
  static const Color glassLight = Color(0x1FFFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);

  // Dashboard
  static const Color dashboardPanel = Color(0xFF172641);
  static const Color dashboardSearch = Color(0xFF24324E);
  static const Color dashboardSectionCard = Color(0x0FFFFFFF);
  static const Color dashboardChip = Color(0xFF26364E);
  static const Color dashboardChipSelected = accent;
  static const Color dashboardMetricTile = primary;
  static const Color dashboardMutedIcon = Color(0x99FFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = primary;

  // Text
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFFB7C7D0);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textLightSecondary = Color(0xFFB7C7D0);

  // Chart colors
  static const List<Color> chartColors = [
    primary,
    accent,
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF63B6F2),
    Color(0xFF86DBC9),
  ];
}
