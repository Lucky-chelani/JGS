import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Brand Colors
  static const Color primaryColor = Color(
    0xFFFF5A5F,
  ); // A vibrant soft red/coral
  static const Color primaryDark = Color(0xFFE03A3E);
  static const Color secondaryColor = Color(0xFF00A699); // Teal
  static const Color accentColor = Color(0xFFFFB400); // Yellow/Gold

  static const Color backgroundColor = Color(0xFFF7F7F9);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF222222);
  static const Color textSecondaryColor = Color(0xFF717171);
  static const Color borderLight = Color(0xFFEBEBEB);

  // ── Cached font families (resolved once) ──
  static final String dmSansFamily = GoogleFonts.dmSans().fontFamily!;
  static final String playfairFamily =
      GoogleFonts.playfairDisplay().fontFamily!;

  // ── Cached theme (built once, never re-created) ──
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: Color(0xFFD32F2F),
    ),
    fontFamily: dmSansFamily,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: playfairFamily,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: playfairFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.3,
        height: 1.15,
      ),
      headlineLarge: TextStyle(
        fontFamily: playfairFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: playfairFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontFamily: dmSansFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontFamily: dmSansFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontFamily: dmSansFamily,
        fontSize: 16,
        color: textPrimaryColor,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: dmSansFamily,
        fontSize: 14,
        color: textSecondaryColor,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: dmSansFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: textPrimaryColor),
      titleTextStyle: TextStyle(
        fontFamily: playfairFamily,
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontFamily: dmSansFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontFamily: dmSansFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      labelStyle: TextStyle(
        fontFamily: dmSansFamily,
        color: textSecondaryColor,
      ),
      hintStyle: TextStyle(
        fontFamily: dmSansFamily,
        color: textSecondaryColor.withOpacity(0.7),
      ),
    ),
  );
}
