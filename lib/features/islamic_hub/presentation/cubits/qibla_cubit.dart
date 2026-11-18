import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../../core/services/compass_service.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/islamic_settings_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

class QiblaState extends Equatable {
  final double qiblaAngle; // Angle to Kaaba from true North (0..360)
  final double currentHeading; // Current device compass heading (0..360)
  final double needleAngle; // Relative needle angle to display
  final String locationLabel;
  final bool isFacingQibla;
  final bool isLoading;
  final bool hasCompassSensor;
  final bool needsCalibration;

  const QiblaState({
    this.qiblaAngle = 135.0, // Default for Cairo approx 136 deg
    this.currentHeading = 0.0,
    this.needleAngle = 135.0,
    this.locationLabel = 'القاهرة، مصر',
    this.isFacingQibla = false,
    this.isLoading = false,
    this.hasCompassSensor = true,
    this.needsCalibration = false,
  });

  QiblaState copyWith({
    double? qiblaAngle,
    double? currentHeading,
    double? needleAngle,
    String? locationLabel,
    bool? isFacingQibla,
    bool? isLoading,
    bool? hasCompassSensor,
    bool? needsCalibration,
  }) {
    return QiblaState(
      qiblaAngle: qiblaAngle ?? this.qiblaAngle,
      currentHeading: currentHeading ?? this.currentHeading,
      needleAngle: needleAngle ?? this.needleAngle,
      locationLabel: locationLabel ?? this.locationLabel,
      isFacingQibla: isFacingQibla ?? this.isFacingQibla,
      isLoading: isLoading ?? this.isLoading,
      hasCompassSensor: hasCompassSensor ?? this.hasCompassSensor,
      needsCalibration: needsCalibration ?? this.needsCalibration,
    );
  }

  @override
  List<Object?> get props => [
        qiblaAngle,
        currentHeading,
        needleAngle,
        locationLabel,
        isFacingQibla,
        isLoading,
        hasCompassSensor,
        needsCalibration,
      ];
}

class QiblaCubit extends Cubit<QiblaState> {
  final IslamicHubRepository _repository;
  final CompassService _compassService;
  final LocationService _locationService;
  StreamSubscription<IslamicSettingsEntity>? _settingsSub;
  StreamSubscription<CompassReading>? _compassSub;
  bool _triedAutoLocation = false;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  QiblaCubit({
    required IslamicHubRepository repository,
    CompassService? compassService,
    LocationService? locationService,
  })  : _repository = repository,
        _compassService = compassService ?? CompassService(),
        _locationService = locationService ?? LocationService(),
        super(const QiblaState()) {
    initQibla();
    _settingsSub = _repository.watchSettings().listen((_) {
      if (!isClosed) {
        initQibla();
      }
    });
  }

  @override
  Future<void> close() {
    _settingsSub?.cancel();
    _compassSub?.cancel();
    return super.close();
  }

  Future<void> initQibla() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    var settings = await _repository.getSettings();
    if (isClosed) return;

    if (settings.isAutoLocationEnabled &&
        settings.customLatitude == null &&
        !_triedAutoLocation) {
      _triedAutoLocation = true;
      try {
        final loc = await _locationService.determineCurrentLocation();
        if (!isClosed &&
            loc.isSuccess &&
            loc.latitude != null &&
            loc.longitude != null) {
          final city = (loc.city != null && loc.city != 'Unknown')
              ? loc.city!
              : settings.selectedCity;
          final country = (loc.country != null && loc.country != 'Unknown')
              ? loc.country!
              : settings.selectedCountry;
          settings = settings.copyWith(
            selectedCity: city,
            selectedCountry: country,
            customLatitude: loc.latitude,
            customLongitude: loc.longitude,
            isAutoLocationEnabled: true,
          );
          await _repository.saveSettings(settings);
        }
      } catch (_) {}
      if (isClosed) return;
    }

    final userLat = settings.customLatitude ?? 30.0444; // Default Cairo
    final userLng = settings.customLongitude ?? 31.2357;

    final qibla = _calculateQiblaBearing(userLat, userLng);
    final location = '${settings.selectedCity}, ${settings.selectedCountry}';
    final relativeAngle = (qibla - state.currentHeading + 360.0) % 360.0;
    final isFacing =
        state.hasCompassSensor && (relativeAngle <= 5.0 || relativeAngle >= 355.0);

    emit(state.copyWith(
      qiblaAngle: qibla,
      needleAngle: relativeAngle,
      locationLabel: location,
      isFacingQibla: isFacing,
      isLoading: false,
    ));
  }

  void startCompass() {
    if (isClosed) return;
    _compassSub?.cancel();
    _compassSub = _compassService.watchHeading().listen(
      (reading) {
        if (isClosed) return;
        if (!reading.isAvailable) {
          emit(state.copyWith(
            hasCompassSensor: false,
            isFacingQibla: false,
            needsCalibration: false,
            needleAngle: state.qiblaAngle,
          ));
          return;
        }
        if (reading.heading != null) {
          updateHeading(reading.heading!, accuracy: reading.accuracy);
        }
      },
      onError: (_) {
        if (!isClosed) {
          emit(state.copyWith(
            hasCompassSensor: false,
            isFacingQibla: false,
            needleAngle: state.qiblaAngle,
          ));
        }
      },
    );
  }

  void stopCompass() {
    _compassSub?.cancel();
    _compassSub = null;
  }

  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * (math.pi / 180.0);
    final lng1 = lng * (math.pi / 180.0);
    const lat2 = _kaabaLat * (math.pi / 180.0);
    const lng2 = _kaabaLng * (math.pi / 180.0);

    final dLng = lng2 - lng1;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    var bearing = math.atan2(y, x) * (180.0 / math.pi);
    bearing = (bearing + 360.0) % 360.0;
    return bearing;
  }

  void updateHeading(double heading, {double? accuracy}) {
    if (isClosed) return;
    final normalizedHeading = ((heading % 360.0) + 360.0) % 360.0;
    // Relative angle to turn needle: Qibla - heading
    final relativeAngle = (state.qiblaAngle - normalizedHeading + 360.0) % 360.0;
    // Check if device is directly facing Qibla within 5 degrees tolerance
    final isFacing = relativeAngle <= 5.0 || relativeAngle >= 355.0;
    final lowAccuracy = accuracy != null &&
        ((!kIsWeb && Platform.isAndroid) ? accuracy <= 1.0 : accuracy > 25.0);

    emit(state.copyWith(
      hasCompassSensor: true,
      currentHeading: normalizedHeading,
      needleAngle: relativeAngle,
      isFacingQibla: isFacing,
      needsCalibration: lowAccuracy,
    ));
  }
}
