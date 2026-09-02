import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/haptic_feedback_helper.dart';

/// A modern frosted glassmorphic card container with backdrop blur,
/// translucent surface, fine border highlight, and optional glowing aura.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.glowColor,
    this.glowRadius,
    this.onTap,
    this.alignment,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? glowColor;
  final double? glowRadius;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.r);
    final effectiveBg = backgroundColor ??
        (isDark ? const Color(0x14FFFFFF) : const Color(0x99FFFFFF));
    final effectiveBorder = borderColor ??
        (isDark ? const Color(0x24FFFFFF) : const Color(0x59FFFFFF));

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(16.r),
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: effectiveBorder,
          width: borderWidth,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: effectiveRadius,
        child: child,
      ),
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (glowColor != null && (glowRadius ?? 0) > 0) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: [
            BoxShadow(
              color: glowColor!,
              blurRadius: glowRadius!,
              spreadRadius: 0,
            ),
          ],
        ),
        child: content,
      );
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: () {
            HapticHelper.light();
            onTap!();
          },
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
