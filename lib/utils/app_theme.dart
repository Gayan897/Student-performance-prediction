import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF185FA5);
  static const Color success = Color(0xFF0F6E56);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFA32D2D);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color border = Color(0xFFE0E0E0);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
          ),
          margin: const EdgeInsets.only(bottom: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFFE8F1FB),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
            }
            return const TextStyle(fontSize: 12, color: Color(0xFF888888));
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: primary, size: 22);
            }
            return const IconThemeData(color: Color(0xFF888888), size: 22);
          }),
        ),
      );

  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A+': return success;
      case 'A': return primary;
      case 'B': return const Color(0xFF3B6D11);
      case 'C': return warning;
      case 'D': return const Color(0xFF993C1D);
      default: return danger;
    }
  }

  static Color riskColor(String risk) {
    switch (risk) {
      case 'Excellent': return success;
      case 'Good': return primary;
      case 'Average': return const Color(0xFF3B6D11);
      case 'Below Average': return warning;
      case 'At Risk': return const Color(0xFF993C1D);
      default: return danger;
    }
  }

  static String gradeEmoji(String grade) {
    switch (grade) {
      case 'A+': return '🏆';
      case 'A': return '⭐';
      case 'B': return '👍';
      case 'C': return '📚';
      case 'D': return '⚠️';
      default: return '🚨';
    }
  }
}