import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  static final _textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(letterSpacing: -0.5, fontWeight: FontWeight.w900),
    displayMedium: GoogleFonts.plusJakartaSans(letterSpacing: -0.5, fontWeight: FontWeight.w900),
    titleLarge: GoogleFonts.plusJakartaSans(letterSpacing: -0.2, fontWeight: FontWeight.w800),
    bodyLarge: GoogleFonts.plusJakartaSans(height: 1.6),
    bodyMedium: GoogleFonts.plusJakartaSans(height: 1.6),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E40AF), // Derived from oklch(0.38 0.16 152) roughly mapped to hex for seed
        primary: const Color(0xFF115E59),
        onPrimary: Colors.white,
        secondary: const Color(0xFFFDE68A),
        onSecondary: const Color(0xFF451A03),
        error: const Color(0xFFDC2626),
        onError: Colors.white,
        surface: const Color(0xFFF8FAFC),
        onSurface: const Color(0xFF0F172A),
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        elevation: 1, // Maps to --elevation-sm
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(
          success: Color(0xFF16A34A),
          onSuccess: Colors.white,
          warning: Color(0xFFF59E0B),
          onWarning: Color(0xFF451A03),
          info: Color(0xFF3B82F6),
          onInfo: Colors.white,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF1E40AF),
        primary: const Color(0xFF2DD4BF),
        onPrimary: const Color(0xFF042F2E),
        secondary: const Color(0xFFFDE68A),
        onSecondary: const Color(0xFF451A03),
        error: const Color(0xFFEF4444),
        onError: const Color(0xFF450A0A),
        surface: const Color(0xFF0F172A),
        onSurface: const Color(0xFFF8FAFC),
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(
          success: Color(0xFF22C55E),
          onSuccess: Color(0xFF052E16),
          warning: Color(0xFFFCD34D),
          onWarning: Color(0xFF451A03),
          info: Color(0xFF60A5FA),
          onInfo: Color(0xFF1E3A8A),
        ),
      ],
    );
  }
}
