import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

/// Central service for playing lightweight, high-quality UI and app sound effects.
/// Combines audio playback with tactile haptic feedback.
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  static SoundEffectsService get instance => _instance;

  /// Whether sound effects are currently muted.
  bool isMuted = false;

  AudioPlayer? _player;

  AudioPlayer _getOrCreatePlayer() {
    _player ??= AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setVolume(0.85);
    return _player!;
  }

  Future<void> _playSound(String assetRelativePath, {bool haptic = true, HapticFeedbackType? hapticType}) async {
    if (isMuted) return;

    if (haptic) {
      _triggerHaptic(hapticType);
    }

    try {
      final player = _getOrCreatePlayer();
      await player.stop();
      await player.play(AssetSource(assetRelativePath));
    } catch (e) {
      AppLogger.warning('⚠️ [SoundEffectsService] Failed to play $assetRelativePath: $e');
    }
  }

  void _triggerHaptic(HapticFeedbackType? type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
      case null:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Subtle tactile click for buttons and list taps
  Future<void> playTap({bool haptic = true}) async {
    await _playSound(
      'audio/ui_tap.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.selection,
    );
  }

  /// Uplifting melodic chime for completed actions, saved changes, or logged sets
  Future<void> playSuccess({bool haptic = true}) async {
    await _playSound(
      'audio/ui_success.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.medium,
    );
  }

  /// Rewarding crystalline chime for coins and points earned
  Future<void> playCoinEarned({bool haptic = true}) async {
    await _playSound(
      'audio/ui_coin.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.light,
    );
  }

  /// Celebratory harmonic chime for streaks, level-ups, and workout completion
  Future<void> playStreakUp({bool haptic = true}) async {
    await _playSound(
      'audio/ui_streak.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.heavy,
    );
  }

  /// Motivating chime when workout rest timer completes
  Future<void> playRestComplete({bool haptic = true}) async {
    await _playSound(
      'audio/rest_complete.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.medium,
    );
  }

  /// Zen bronze bell when pomodoro timer completes
  Future<void> playPomodoroComplete({bool haptic = true}) async {
    await _playSound(
      'audio/pomodoro_complete.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.medium,
    );
  }

  /// Notification chime
  Future<void> playNotificationSound({bool haptic = true}) async {
    await _playSound(
      'audio/notification_sound.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.light,
    );
  }

  /// Calm singing bowl tone for meditation and stress relief
  Future<void> playSosChime({bool haptic = true}) async {
    await _playSound(
      'audio/sos_chime.mp3',
      haptic: haptic,
      hapticType: HapticFeedbackType.light,
    );
  }

  /// Dispose of the underlying audio player
  void dispose() {
    try {
      _player?.dispose();
      _player = null;
    } catch (e) {
      AppLogger.warning('⚠️ [SoundEffectsService] dispose error: $e');
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}
