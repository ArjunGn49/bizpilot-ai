import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Palette - Modern Indigo & Slate
  static const _primaryLight = Color(0xFF2563EB); // Vibrant Indigo
  static const _primaryContainerLight = Color(0xFFEFF6FF);
  static const _secondaryLight = Color(0xFF10B981); // Emerald Green Accent
  static const _surfaceLight = Color(0xFFF8FAFC); // Clean Slate Background
  static const _cardSurfaceLight = Colors.white;
  static const _textPrimaryLight = Color(0xFF0F172A); // Deep Slate Text
  static const _textSecondaryLight = Color(0xFF64748B); // Muted Text

  // Dark Theme Palette - Modern Dark Slate
  static const _primaryDark = Color(0xFF60A5FA); // Bright Sky Blue
  static const _primaryContainerDark = Color(0xFF1E293B);
  static const _secondaryDark = Color(0xFF34D399);
  static const _surfaceDark = Color(0xFF0F172A); // Midnight Slate
  static const _cardSurfaceDark = Color(0xFF1E293B);
  static const _textPrimaryDark = Color(0xFFF8FAFC);
  static const _textSecondaryDark = Color(0xFF94A3B8);

  static TextTheme _buildTextTheme(Brightness brightness, Color textColor) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    final coloredTheme = baseTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
    try {
      return GoogleFonts.plusJakartaSansTextTheme(coloredTheme);
    } catch (_) {
      return coloredTheme;
    }
  }

  static String? _getFontFamily() {
    try {
      return GoogleFonts.plusJakartaSans().fontFamily;
    } catch (_) {
      return null;
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _getFontFamily(),
    textTheme: _buildTextTheme(Brightness.light, _textPrimaryLight),
    colorScheme: ColorScheme.light(
      primary: _primaryLight,
      primaryContainer: _primaryContainerLight,
      onPrimaryContainer: _primaryLight,
      secondary: _secondaryLight,
      surface: _surfaceLight,
      onSurface: _textPrimaryLight,
      onSurfaceVariant: _textSecondaryLight,
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE2E8F0),
      error: const Color(0xFFEF4444),
    ),
    scaffoldBackgroundColor: _surfaceLight,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.2,
        fontFamily: _getFontFamily(),
      ),
    ),
    cardTheme: CardThemeData(
      color: _cardSurfaceLight,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      labelStyle: TextStyle(
          color: _textSecondaryLight,
          fontSize: 14,
          fontFamily: _getFontFamily()),
      hintStyle: TextStyle(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
          fontFamily: _getFontFamily()),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          fontFamily: _getFontFamily(),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimaryLight,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          fontFamily: _getFontFamily(),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primaryContainerLight,
      selectedColor: _primaryLight,
      secondarySelectedColor: _primaryLight,
      labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: _getFontFamily()),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _cardSurfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _getFontFamily(),
    textTheme: _buildTextTheme(Brightness.dark, _textPrimaryDark),
    colorScheme: ColorScheme.dark(
      primary: _primaryDark,
      primaryContainer: _primaryContainerDark,
      onPrimaryContainer: _primaryDark,
      secondary: _secondaryDark,
      surface: _surfaceDark,
      onSurface: _textPrimaryDark,
      onSurfaceVariant: _textSecondaryDark,
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
      error: const Color(0xFFF87171),
    ),
    scaffoldBackgroundColor: _surfaceDark,
    appBarTheme: AppBarTheme(
      backgroundColor: _cardSurfaceDark,
      foregroundColor: _textPrimaryDark,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
        letterSpacing: -0.2,
        fontFamily: _getFontFamily(),
      ),
    ),
    cardTheme: CardThemeData(
      color: _cardSurfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _cardSurfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      labelStyle: TextStyle(
          color: _textSecondaryDark,
          fontSize: 14,
          fontFamily: _getFontFamily()),
      hintStyle: TextStyle(
          color: const Color(0xFF64748B),
          fontSize: 14,
          fontFamily: _getFontFamily()),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          fontFamily: _getFontFamily(),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimaryDark,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: Color(0xFF334155)),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          fontFamily: _getFontFamily(),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: Colors.black,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primaryContainerDark,
      selectedColor: _primaryDark,
      secondarySelectedColor: _primaryDark,
      labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: _getFontFamily()),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _cardSurfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
