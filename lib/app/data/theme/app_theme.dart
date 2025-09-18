import 'package:flutter/material.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'app_colors.dart';

class AppTheme {
  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),

    inputDecorationTheme: _inputDecorationTheme(
      fillColor: AppColors.darkSurface,
      labelColor: AppColors.darkTextSecondary,
      borderColor: AppColors.primary,
    ),

    elevatedButtonTheme: _elevatedButtonTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    outlinedButtonTheme: _outlinedButtonTheme(
      foregroundColor: AppColors.darkTextPrimary,
      borderColor: AppColors.darkTextSecondary.withOpacityValue(0.5),
    ),

    textButtonTheme: _textButtonTheme(foregroundColor: AppColors.primary),
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),

    inputDecorationTheme: _inputDecorationTheme(
      fillColor: AppColors.lightSurface,
      labelColor: AppColors.lightTextSecondary,
      borderColor: AppColors.primary,
    ),

    elevatedButtonTheme: _elevatedButtonTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    outlinedButtonTheme: _outlinedButtonTheme(
      foregroundColor: AppColors.lightTextPrimary,
      borderColor: AppColors.lightTextSecondary.withOpacityValue(0.5),
    ),

    textButtonTheme: _textButtonTheme(foregroundColor: AppColors.primary),
  );

  // --- PRIVATE HELPERS FOR CONSISTENT STYLING ---

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color labelColor,
    required Color borderColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: labelColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({
    required Color foregroundColor,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
