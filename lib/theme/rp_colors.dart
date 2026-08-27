import 'package:flutter/material.dart';

/// Visual tokens mirrored from the Next.js app (`globals.css` `--rp-*`).
abstract final class RpColors {
  static const bg = Color(0xFFFFF8F5);
  static const bgElevated = Color(0xFFFFFFFF);
  static const bgMuted = Color(0xFFF3EEF8);
  static const fieldFill = Color(0xFFFAFAFA);

  static const heroStart = Color(0xFFE8F4FF);
  static const heroMid = Color(0xFFFFE8F3);
  static const heroEnd = Color(0xFFFFF3D6);

  static const purple = Color(0xFF8B7CFF);
  static const purpleSoft = Color(0xFFC9C0FF);
  static const purpleDeep = Color(0xFF4A3ABA);
  static const peach = Color(0xFFFF8A71);
  static const peachDeep = Color(0xFFF56B52);
  static const pink = Color(0xFFFF7AB6);
  static const mint = Color(0xFF6FCFB2);
  static const sky = Color(0xFF7EB6FF);
  static const yellow = Color(0xFFFFD66B);

  static const text = Color(0xFF2A2A4A);
  static const textSecondary = Color(0xFF6B6B8A);
  static const success = Color(0xFF3DCC8A);
  static const danger = Color(0xFFFF5C7A);

  static const border = Color(0x142A2A4A);
  static const focusRing = Color(0xFF8B7CFF);
  static const focusGlow = Color(0x268B7CFF);

  static const hirncoin = Color(0xFFF5A623);
  static const hirncoinSoft = Color(0xFFFFE8B8);
  static const streakWash = Color(0xFFFFF0F0);

  static const cardShadow = Color(0x142A2A4A);
  static const peachShadow = Color(0x59FF8A71);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroStart, heroMid, heroEnd],
    stops: [0.0, 0.45, 1.0],
  );

  static const wordmarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, pink, peach],
  );

  static const peachButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peach, peachDeep],
  );
}
