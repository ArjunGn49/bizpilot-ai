import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1976D2), // Primary color (Colors.blue.shade700)
      onPrimary: Colors.white, // Text/icon color on primary
      secondary: const Color(0xFF26A69A), // Secondary color (Colors.teal.shade400)
      onSecondary: Colors.white, // Text/icon color on secondary
      error: const Color(0xFFD32F2F), // Error color (Colors.red.shade700)
      onError: Colors.white, // Text/icon color on error
      surface: const Color(0xFFF5F5F5), // Page background (Colors.grey.shade100)
      onSurface: const Color(0xFF212121), // Text/icon color on background (Colors.grey.shade900)
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Default scaffold background (Colors.grey.shade100)
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1976D2), // Colors.blue.shade700
      foregroundColor: Colors.white, // Title and icon color
      elevation: 0, // No shadow
    ),
    // Define other theme properties like textTheme, inputDecorationTheme, etc.
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF212121)), // Default text color (Colors.grey.shade900)
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFA0C4F7), // Primary color (Colors.blue.shade300)
      onPrimary: Colors.black, // Text/icon color on primary
      secondary: const Color(0xFF80CBC4), // Secondary color (Colors.teal.shade200)
      onSecondary: Colors.black, // Text/icon color on secondary
      error: const Color(0xFFEF9A9A), // Error color (Colors.red.shade300)
      onError: Colors.black, // Text/icon color on error
      surface: const Color(0xFF424242), // Page background (Colors.grey.shade800)
      onSurface: const Color(0xFFF5F5F5), // Text/icon color on background (Colors.grey.shade100)
    ),
    scaffoldBackgroundColor: const Color(0xFF424242), // Default scaffold background (Colors.grey.shade800)
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF424242), // Colors.grey.shade800
      foregroundColor: const Color(0xFFF5F5F5), // Colors.grey.shade100
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFF5F5F5)), // Default text color (Colors.grey.shade100)
    ),
  );
}
