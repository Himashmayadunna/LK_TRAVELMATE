import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color primaryDark = Color(0xFF465A95);
  static const Color primary = Color(0xFF5E71B3);
  static const Color primaryLight = Color(0xFF5E71B3);
  static const Color primaryAccent = Color(0xFFFC9428);
  static const Color primarySoft = Color(0xFFDCE3F4);
  static const Color primarySurface = Color(0xFFEEF2FB);

  // Accent palette
  static const Color accent = Color(0xFFFC9428);
  static const Color accentLight = Color(0xFFFDC27D);
  static const Color gold = Color(0xFFFC9428);
  static const Color goldLight = Color(0xFFFED8AD);

  // Neutrals
  static const Color textPrimary = Color(0xFF24314F);
  static const Color textSecondary = Color(0xFF667497);
  static const Color textHint = Color(0xFF9AA6C0);
  static const Color background = Color(0xFFF6F8FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFDCE3F0);
  static const Color cardShadow = Color(0x1A465A95);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFC9428);
  static const Color error = Color(0xFFE53935);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 50.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textHint,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textHint,
    letterSpacing: 0.3,
  );

  // Box Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(color: cardShadow, blurRadius: 20, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: cardShadow.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  // ThemeData
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      tertiary: accentLight,
      primaryContainer: primarySurface,
      surface: surface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
