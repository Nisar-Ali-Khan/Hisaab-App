import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  final Color ink;
  final Color navy;
  final Color navyDeep;
  final Color teal;
  final Color tealLight;
  final Color cream;
  final Color creamDeep;
  final Color gold;
  final Color rose;
  final Color white;
  final Color muted;

  const AppColors({
    required this.ink,
    required this.navy,
    required this.navyDeep,
    required this.teal,
    required this.tealLight,
    required this.cream,
    required this.creamDeep,
    required this.gold,
    required this.rose,
    required this.white,
    required this.muted,
  });

  static const light = AppColors(
    ink: Color(0xFF14213D),
    navy: Color(0xFF1C2B4A),
    navyDeep: Color(0xFF0E1830),
    teal: Color(0xFF2A9D8F),
    tealLight: Color(0xFF8FC9C0),
    cream: Color(0xFFF7F4EE),
    creamDeep: Color(0xFFEDE6D6),
    gold: Color(0xFFE9B44C),
    rose: Color(0xFFC44536),
    white: Color(0xFFFFFEFC),
    muted: Color(0xFF8C8577),
  );

  static const dark = AppColors(
    ink: Color(0xFFE2E8F0),
    navy: Color(0xFF4A6DA7), // Lighter navy for text
    navyDeep: Color(0xFF0B1221), // Darker background
    teal: Color(0xFF38B2A3),
    tealLight: Color(0xFF236B62),
    cream: Color(0xFF121B2B), // Very dark blue/gray
    creamDeep: Color(0xFF1A263D), // Slightly lighter than cream
    gold: Color(0xFFF0C46B),
    rose: Color(0xFFD65A4B),
    white: Color(0xFF1C2B4A), // Use dark navy for "white" cards
    muted: Color(0xFF94A3B8),
  );
}

extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}

class AppText {
  static TextStyle display(BuildContext context, {double size = 24, FontWeight weight = FontWeight.w600, Color? color}) {
    return GoogleFonts.lora(fontSize: size, fontWeight: weight, color: color ?? context.colors.ink);
  }

  static TextStyle body(BuildContext context, {double size = 14, FontWeight weight = FontWeight.w400, Color? color}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? context.colors.ink);
  }

  static TextStyle mono(BuildContext context, {double size = 12, FontWeight weight = FontWeight.w500, Color? color}) {
    return GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color ?? context.colors.navy);
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.light.cream,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.light.navy, brightness: Brightness.light),
    useMaterial3: true,
  );
}

ThemeData buildAppThemeDark() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.dark.cream,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.dark.navy, brightness: Brightness.dark),
    useMaterial3: true,
  );
}
