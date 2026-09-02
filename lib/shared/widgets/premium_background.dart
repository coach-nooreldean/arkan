import 'package:flutter/material.dart';

/// Reusable premium background for main dashboard and flagship screens.
/// Features a deep, clean, velvety obsidian surface in dark mode and crisp porcelain in light mode.
class PremiumBackground extends StatelessWidget {
  const PremiumBackground({
    super.key,
    required this.child,
    this.showGlow = false,
  });

  final Widget child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // Deep subtle navy-slate tone at top
                  Color(0xFF0B0F19), // Pure rich obsidian black
                  Color(0xFF070A10), // Deep ground
                ],
                stops: [0.0, 0.4, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC), // Pure porcelain
                  Color(0xFFF1F5F9), // Subtle slate tint
                ],
              ),
      ),
      child: child,
    );
  }
}
