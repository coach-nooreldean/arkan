import 'package:flutter/material.dart';

/// Predefined box shadows aligned with Material 3 elevation tiers.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppShadows.card,
///   ),
/// )
/// ```
abstract final class AppShadows {
  AppShadows._();

  /// No shadow — flat, tonal surface (elevation 0).
  static const List<BoxShadow> none = [];

  /// Minimal shadow — barely lifted surfaces (elevation 1).
  /// Use for: toggle surfaces, filled cards on white background.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Card shadow — clearly elevated content (elevation 2–3).
  /// Use for: cards, list items that are tappable, floating elements.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated shadow — significantly raised surface (elevation 6–8).
  /// Use for: FABs, dropdown menus, tooltips.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Glass shadow — smooth floating effect for glassmorphic panels.
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// Glowing brand athletic blue shadow for primary cards, CTAs, and active tabs.
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x4D3551AE), // 30% royal blue
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  /// Glowing royal electric accent shadow for data metrics, streaks, and PRs.
  static const List<BoxShadow> glowAccent = [
    BoxShadow(
      color: Color(0x4D2563EB), // 30% electric blue
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];
  /// Dynamic glowing shadow using any theme primary/accent color.
  static List<BoxShadow> glow(Color color, {double opacity = 0.3, double blur = 24}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: blur,
      offset: const Offset(0, 4),
    ),
  ];
}
