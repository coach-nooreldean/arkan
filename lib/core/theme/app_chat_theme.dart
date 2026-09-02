import 'package:flutter/material.dart';

/// Chat-specific styling constants.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: isMe ? AppChatTheme.outgoingBubble : AppChatTheme.incomingBubbleLight,
///     borderRadius: AppChatTheme.bubbleBorder(isMe: isMe),
///   ),
/// )
/// ```
abstract final class AppChatTheme {
  AppChatTheme._();

  // ── Colors ────────────────────────────────────────────────────────────────

  /// Active brand theme color used for outgoing bubbles, seekbar tracks, and active indicators.
  static const Color primaryBrand = Color(0xFF3551AE);

  /// Outgoing message bubble background color.
  static const Color outgoingBubble = primaryBrand;

  /// Incoming message bubble background color (Light mode).
  static const Color incomingBubbleLight = Color(0xFFF1F3F9);

  /// Incoming message bubble background color (Dark mode).
  static const Color incomingBubbleDark = Color(0xFF1E293B);

  // ── Borders & Radii ────────────────────────────────────────────────────────

  /// Default border radius for standard chat message corners.
  static const double bubbleRadius = 16;

  /// Reduced border radius for the message "tail" corner.
  static const double bubbleTailRadius = 4;

  /// Calculates the appropriate bubble border radius based on sender identity.
  static BorderRadius bubbleBorder({
    required bool isMe,
    double radius = bubbleRadius,
    double tailRadius = bubbleTailRadius,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(isMe ? radius : tailRadius),
      bottomRight: Radius.circular(isMe ? tailRadius : radius),
    );
  }

  // ── Sizing & Constraints ──────────────────────────────────────────────────

  /// Maximum screen width ratio constraint for message content.
  static const double maxBubbleWidthRatio = 0.75;

  /// Maximum height limit for the typing composer text area.
  static const double maxComposerHeight = 120;
}
