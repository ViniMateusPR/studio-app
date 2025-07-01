import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const onSurface = Colors.white;
  static const onSurfaceLight = Colors.white70;
  static const accent = Color(0xFFFF6B00);
  static const error = Colors.redAccent;
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    color: AppColors.onSurface,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const titleMedium = TextStyle(
    color: AppColors.onSurfaceLight,
    fontSize: 16,
  );
  static const bodyMedium = TextStyle(
    color: AppColors.onSurface,
    fontSize: 14,
  );
  static const labelLarge = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}

final appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.error,
    background: AppColors.primary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 0,
    titleTextStyle: AppTextStyles.titleLarge,
    iconTheme: IconThemeData(color: AppColors.onSurface),
  ),
  textTheme: const TextTheme(
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    bodyMedium: AppTextStyles.bodyMedium,
    labelLarge: AppTextStyles.labelLarge,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    labelStyle: const TextStyle(color: AppColors.onSurfaceLight),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onSurface,
      minimumSize: const Size.fromHeight(48),
      textStyle: AppTextStyles.labelLarge,
    ),
  ),
);
