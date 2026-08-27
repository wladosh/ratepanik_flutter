import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rp_colors.dart';

abstract final class RpRadii {
  static const md = 20.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

ThemeData buildRpTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RpColors.purple,
      brightness: Brightness.light,
      primary: RpColors.purple,
      secondary: RpColors.peach,
      surface: RpColors.bgElevated,
      error: RpColors.danger,
    ),
    scaffoldBackgroundColor: RpColors.bg,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(
    base.textTheme,
  ).apply(bodyColor: RpColors.text, displayColor: RpColors.text);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: RpColors.text,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: RpColors.purple,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RpColors.fieldFill,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RpRadii.md),
        borderSide: const BorderSide(color: RpColors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RpRadii.md),
        borderSide: const BorderSide(color: RpColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RpRadii.md),
        borderSide: const BorderSide(color: RpColors.focusRing, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RpRadii.md),
        borderSide: const BorderSide(color: RpColors.danger, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RpRadii.md),
        borderSide: const BorderSide(color: RpColors.danger, width: 2),
      ),
    ),
  );
}
