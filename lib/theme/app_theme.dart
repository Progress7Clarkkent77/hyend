import 'package:flutter/material.dart';

class AppColors {
  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFF1D77A);
  static const navy = Color(0xFF0A1020);
  static const navyLight = Color(0xFF131C33);
  static const ivory = Color(0xFFF7F5EF);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      surface: AppColors.navyLight,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.ivory,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      surface: Colors.white,
    ),
  );
}
