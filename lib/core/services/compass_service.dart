import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';

/// Represents a single reading from the device's magnetic/compass sensor.
class CompassReading {
  final bool isAvailable;
  final double? heading;
  final double? accuracy;

  const CompassReading({
    required this.isAvailable,
    this.heading,
    this.accuracy,
  });
}

/// Cross-platform compass service backed by native Android/iOS sensor EventChannel.
/// Applies shortest-arc circular smoothing to avoid 359° <-> 0° wraparound jumps.
class CompassService {
  static const EventChannel _channel = EventChannel('com.arkan.arkan/compass');
  static const double _smoothingAlpha = 0.25;

  final Stream<CompassReading> Function()? _streamOverride;

  CompassService({Stream<CompassReading> Function()? streamOverride})
      : _streamOverride = streamOverride;

  /// Applies exponential smoothing on a circular [0, 360) domain using the shortest arc.
  static double applyCircularSmoothing(
    double rawHeading,
    double? previousHeading, {
    double alpha = _smoothingAlpha,
  }) {
    final normalizedRaw = ((rawHeading % 360.0) + 360.0) % 360.0;
    if (previousHeading == null) return normalizedRaw;
    final delta = ((normalizedRaw - previousHeading + 540.0) % 360.0) - 180.0;
    return ((previousHeading + alpha * delta) % 360.0 + 360.0) % 360.0;
  }

  /// Streams smoothed device compass headings (0..360, clockwise from North),
  /// or emits a single `isAvailable: false` event on unsupported platforms/devices.
  Stream<CompassReading> watchHeading() {
    if (_streamOverride != null) {
      return _streamOverride();
    }

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return Stream<CompassReading>.value(
        const CompassReading(isAvailable: false),
      );
    }

    double? smoothedHeading;

    return _channel.receiveBroadcastStream().transform(
      StreamTransformer<dynamic, CompassReading>.fromHandlers(
        handleData: (dynamic event, EventSink<CompassReading> sink) {
          if (event is! Map) return;
          final available = event['available'] == true;
          if (!available) {
            sink.add(const CompassReading(isAvailable: false));
            return;
          }

          final rawNum = event['heading'];
          if (rawNum is! num) return;

          smoothedHeading = applyCircularSmoothing(
            rawNum.toDouble(),
            smoothedHeading,
          );

          final accNum = event['accuracy'];
          sink.add(
            CompassReading(
              isAvailable: true,
              heading: smoothedHeading,
              accuracy: accNum is num ? accNum.toDouble() : null,
            ),
          );
        },
        handleError: (Object error, StackTrace stackTrace, EventSink<CompassReading> sink) {
          sink.add(const CompassReading(isAvailable: false));
        },
      ),
    );
  }
}
