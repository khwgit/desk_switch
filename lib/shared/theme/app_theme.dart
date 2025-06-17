import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        minWidth: 72,
        minExtendedWidth: 196,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          // minimumSize: Size.zero,
          // iconSize: 24,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        brightness: Brightness.dark,
      ),
    );
  }
}
