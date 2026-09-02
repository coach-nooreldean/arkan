import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// App-specific colors that aren't part of the standard [ColorScheme].
/// Access via `context.appColors` (defined in `context_extension.dart`).
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    this.successContainer,
    this.onSuccessContainer,
    this.warningContainer,
    this.onWarningContainer,
    this.infoContainer,
    this.onInfoContainer,
    this.accent = const Color(0xFF06B6D4),
    this.glassSurface = const Color(0x1AFFFFFF),
    this.glassBorder = const Color(0x24FFFFFF),
    this.glowPrimary = const Color(0x592563EB),
    this.glowAccent = const Color(0x5906B6D4),
    this.isFemale = false,
    this.logoAsset = AppAssets.logo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? infoContainer;
  final Color? onInfoContainer;
  final Color accent;
  final Color glassSurface;
  final Color glassBorder;
  final Color glowPrimary;
  final Color glowAccent;
  final bool isFemale;
  final String logoAsset;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? accent,
    Color? glassSurface,
    Color? glassBorder,
    Color? glowPrimary,
    Color? glowAccent,
    bool? isFemale,
    String? logoAsset,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      accent: accent ?? this.accent,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glowPrimary: glowPrimary ?? this.glowPrimary,
      glowAccent: glowAccent ?? this.glowAccent,
      isFemale: isFemale ?? this.isFemale,
      logoAsset: logoAsset ?? this.logoAsset,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t) ?? glassSurface,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t) ?? glassBorder,
      glowPrimary: Color.lerp(glowPrimary, other.glowPrimary, t) ?? glowPrimary,
      glowAccent: Color.lerp(glowAccent, other.glowAccent, t) ?? glowAccent,
      isFemale: other.isFemale,
      logoAsset: other.logoAsset,
    );
  }
}

/// Helper class to define the actual color palettes
class AppPalettes {
  AppPalettes._();

  static const light = AppColorsExtension(
    success: Color(0xFF10B981),
    onSuccess: Colors.white,
    successContainer: Color(0xFFA5D6A7),
    onSuccessContainer: Color(0xFF1B5E20),
    warning: Color(0xFFF59E0B),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFCC80),
    onWarningContainer: Color(0xFFE65100),
    info: Color(0xFF2563EB), // Pure athletic royal blue
    onInfo: Colors.white,
    infoContainer: Color(0xFFDBEAFE),
    onInfoContainer: Color(0xFF1E3A8A),
    accent: Color(0xFF3551AE), // Brand royal blue
    glassSurface: Color(0xA6FFFFFF), // 65% white for light glass
    glassBorder: Color(0x59FFFFFF), // 35% translucent border
    glowPrimary: Color(0x3D3551AE),
    glowAccent: Color(0x3D2563EB),
    isFemale: false,
    logoAsset: AppAssets.logo,
  );

  static const dark = AppColorsExtension(
    success: Color(0xFF10B981),
    onSuccess: Color(0xFF003300),
    successContainer: Color(0xFF1B5E20),
    onSuccessContainer: Color(0xFFA5D6A7),
    warning: Color(0xFFF59E0B),
    onWarning: Color(0xFF5D4037),
    warningContainer: Color(0xFFE65100),
    onWarningContainer: Color(0xFFFFCC80),
    info: Color(0xFF2563EB),
    onInfo: Color(0xFFDBEAFE),
    infoContainer: Color(0xFF1E3A8A),
    onInfoContainer: Color(0xFFEFF6FF),
    accent: Color(0xFF3551AE), // Brand royal blue
    glassSurface: Color(0x1AFFFFFF), // 10% translucent white for dark glass
    glassBorder: Color(0x29FFFFFF), // 16% translucent border
    glowPrimary: Color(0x663551AE),
    glowAccent: Color(0x662563EB),
    isFemale: false,
    logoAsset: AppAssets.logo,
  );

  static const femaleLight = AppColorsExtension(
    success: Color(0xFF10B981),
    onSuccess: Colors.white,
    successContainer: Color(0xFFA5D6A7),
    onSuccessContainer: Color(0xFF1B5E20),
    warning: Color(0xFFF59E0B),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFCC80),
    onWarningContainer: Color(0xFFE65100),
    info: Color(0xFFEC4899),
    onInfo: Colors.white,
    infoContainer: Color(0xFFFCE7F3),
    onInfoContainer: Color(0xFF831843),
    accent: Color(0xFFE83D84), // Brand Vibrant Athletic Pink
    glassSurface: Color(0xA6FFFFFF),
    glassBorder: Color(0x59FFFFFF),
    glowPrimary: Color(0x3DE83D84),
    glowAccent: Color(0x3DEC4899),
    isFemale: true,
    logoAsset: AppAssets.logoFemale,
  );

  static const femaleDark = AppColorsExtension(
    success: Color(0xFF10B981),
    onSuccess: Color(0xFF003300),
    successContainer: Color(0xFF1B5E20),
    onSuccessContainer: Color(0xFFA5D6A7),
    warning: Color(0xFFF59E0B),
    onWarning: Color(0xFF5D4037),
    warningContainer: Color(0xFFE65100),
    onWarningContainer: Color(0xFFFFCC80),
    info: Color(0xFFEC4899),
    onInfo: Color(0xFFFCE7F3),
    infoContainer: Color(0xFF831843),
    onInfoContainer: Color(0xFFFDF2F8),
    accent: Color(0xFFE83D84), // Brand Vibrant Athletic Pink
    glassSurface: Color(0x1AFFFFFF),
    glassBorder: Color(0x29FFFFFF),
    glowPrimary: Color(0x66E83D84),
    glowAccent: Color(0x66EC4899),
    isFemale: true,
    logoAsset: AppAssets.logoFemale,
  );
}
