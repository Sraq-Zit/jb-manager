import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2B7FFF);
  static const Color secondaryColor = Color(0xFF00C951);
  static const Color backgroundColor = Color(
    0xFFF9FAFB,
  ); // Light Gray Background
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color whiteColor = Colors.white;
  static const Color shadowColor = Colors.black;

  static const _inputRadius = 16.0;

  static ThemeData get themeData {
    return ThemeData(
      highlightColor: secondaryColor.withValues(alpha: 0.05),
      splashColor: primaryColor.withValues(alpha: 0.1),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.inter(
          color: textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.inter(
          color: textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(color: Colors.transparent),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: Colors.grey, width: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        filled: true,
        fillColor: Colors.transparent,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIconColor: Colors.grey.shade600,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(_inputRadius),
        ),
      ),
    );
  }
}
