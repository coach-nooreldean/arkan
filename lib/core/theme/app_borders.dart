import 'package:flutter/material.dart';

/// Reusable border radii and border shapes used across the app.
///
/// Usage:
/// ```dart
/// Container(decoration: BoxDecoration(borderRadius: AppBorders.md))
/// ```
abstract final class AppBorders {
  AppBorders._();

  // ── Border Radii ──────────────────────────────────────────────────────────

  /// 4 pt — subtle rounding, used for small chips, badges.
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));

  /// 8 pt — standard rounding for buttons, text fields.
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));

  /// 12 pt — medium rounding for cards, list tiles.
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));

  /// 16 pt — large rounding for modals, bottom sheets.
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));

  /// 24 pt — extra large rounding for dialogs, feature cards.
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));

  /// 28 pt — Material 3 bottom sheet top radius.
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(28),
  );

  /// Fully circular (pill/stadium shape).
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));

  // ── Semantic aliases ──────────────────────────────────────────────────────

  /// Default button border radius (Pill / Capsule 9999px).
  static const BorderRadius button = full;

  /// Default card border radius (Modern rounded 20-24px).
  static const BorderRadius card = xl;

  /// Default input field border radius.
  static const BorderRadius input = md;

  /// Default dialog border radius.
  static const BorderRadius dialog = xl;

  // ── RoundedRectangleBorder shapes (for ShapeBorder APIs) ─────────────────

  /// Small rounded rectangle shape (8 pt).
  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(
    borderRadius: sm,
  );

  /// Medium rounded rectangle shape (12 pt).
  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: md,
  );

  /// Large rounded rectangle shape (16 pt).
  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(
    borderRadius: lg,
  );

  /// Fully circular/stadium shape.
  static const StadiumBorder stadium = StadiumBorder();
}
