import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the official Material 3 typescale for NoorEldean Coaching:
/// - Display & Headlines & Titles: Tajawal (Bold, crisp, geometric Arabic/English)
/// - Body & Labels: Cairo (Generous 1.8 line height for smooth Arabic legibility)
TextTheme buildTextTheme() {
  TextTheme displayBase;
  TextTheme bodyBase;
  try {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      displayBase = Typography.material2021().black;
      bodyBase = Typography.material2021().black;
    } else {
      displayBase = GoogleFonts.tajawalTextTheme();
      bodyBase = GoogleFonts.cairoTextTheme();
    }
  } catch (_) {
    displayBase = Typography.material2021().black;
    bodyBase = Typography.material2021().black;
  }

  return TextTheme(
    // ── Display (Tajawal) ──────────────────────────────────────────
    displayLarge: displayBase.displayLarge?.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    displayMedium: displayBase.displayMedium?.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.3,
    ),
    displaySmall: displayBase.displaySmall?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.3,
    ),

    // ── Headline (Tajawal) ─────────────────────────────────────────
    headlineLarge: displayBase.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.4,
    ),
    headlineMedium: displayBase.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.4,
    ),
    headlineSmall: displayBase.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.4,
    ),

    // ── Title (Tajawal) ────────────────────────────────────────────
    titleLarge: displayBase.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleMedium: displayBase.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleSmall: displayBase.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
    ),

    // ── Body (Cairo - High Arabic Legibility) ───────────────────────
    bodyLarge: bodyBase.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.8,
    ),
    bodyMedium: bodyBase.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.8,
    ),
    bodySmall: bodyBase.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.7,
    ),

    // ── Label (Cairo) ──────────────────────────────────────────────
    labelLarge: bodyBase.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    labelMedium: bodyBase.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    labelSmall: bodyBase.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.5,
    ),
  );
}
