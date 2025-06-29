import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

class AppTheme {
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
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

  ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        brightness: Brightness.dark,
      ),
    );
  }
}
