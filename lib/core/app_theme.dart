import 'package:flutter/material.dart';

class AppTheme {
  // Dark Purple UI Kit Palette (Task Planner & Management styling)
  static const background = Color(0xFF0F0B1E); // Deep midnight purple background
  static const surface = Color(0xFF1B1435);    // Dark purple card container
  static const surfaceLight = Color(0xFF261D47); // Lighter dark purple for inputs/elevation
  static const surfaceBorder = Color(0xFF33275B); // Subtle border color for cards
  
  static const purple = Color(0xFF7C3AED);     // Electric vibrant purple
  static const purpleLight = Color(0xFFA78BFA); // Soft violet / subtext accent
  static const yellow = Color(0xFFFFD500);      // Bright electric yellow / amber CTA accent
  static const yellowDark = Color(0xFFE5BE00);  // Darker yellow
  static const pink = Color(0xFFEC4899);        // Vivid magenta / pink badge accent
  static const muted = Color(0xFF8B85AA);       // Subtitle / muted text color
  static const ink = Color(0xFFF3F0FF);         // Primary light text color

  // Legacy color aliases for compatibility across screens
  static const navy = Color(0xFFF3F0FF);        // Text header color (bright white/violet)
  static const blue = Color(0xFF7C3AED);        // Primary vibrant accent
  static const teal = Color(0xFFA78BFA);        // Sub-heading accent
  static const pale = Color(0xFF261D47);        // Input container background

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFD500), Color(0xFFFF9900)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF231A45), Color(0xFF191235)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light => dark; // Default to sleek dark UI kit theme

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: purple,
      secondary: yellow,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: ink,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: ink, fontSize: 20, fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      hintStyle: const TextStyle(color: muted, fontSize: 14),
      labelStyle: const TextStyle(color: purpleLight, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: purple, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: surfaceBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF140D2B),
      indicatorColor: purple.withOpacity(0.25),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: yellow, size: 24);
        }
        return const IconThemeData(color: muted, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: yellow, fontWeight: FontWeight.w800, fontSize: 12);
        }
        return const TextStyle(color: muted, fontWeight: FontWeight.w600, fontSize: 12);
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return purple;
          return surfaceLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return purpleLight;
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    ),
  );
}

