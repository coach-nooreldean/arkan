import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/islamic_settings_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

class QiblaState extends Equatable {
  final double qiblaAngle; // Angle to Kaaba from true North (0..360)
  final double currentHeading; // Current device compass heading (0..360)
  final double needleAngle; // Relative needle angle to display
  final String locationLabel;
  final bool isFacingQibla;
  final bool isLoading;

  const QiblaState({
    this.qiblaAngle = 135.0, // Default for Cairo approx 136 deg
    this.currentHeading = 0.0,
    this.needleAngle = 135.0,
    this.locationLabel = 'القاهرة، مصر',
    this.isFacingQibla = false,
    this.isLoading = false,
  });

  QiblaState copyWith({
    double? qiblaAngle,
    double? currentHeading,
    double? needleAngle,
    String? locationLabel,
    bool? isFacingQibla,
    bool? isLoading,
  }) {
    return QiblaState(
      qiblaAngle: qiblaAngle ?? this.qiblaAngle,
      currentHeading: currentHeading ?? this.currentHeading,
      needleAngle: needleAngle ?? this.needleAngle,
      locationLabel: locationLabel ?? this.locationLabel,
      isFacingQibla: isFacingQibla ?? this.isFacingQibla,
      isLoading: isLoading ?? this.isLoading,
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
      ];
}

class QiblaCubit extends Cubit<QiblaState> {
  final IslamicHubRepository _repository;
  StreamSubscription<IslamicSettingsEntity>? _settingsSub;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  QiblaCubit({required IslamicHubRepository repository})
      : _repository = repository,
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
    return super.close();
  }

  Future<void> initQibla() async {
    emit(state.copyWith(isLoading: true));
    final settings = await _repository.getSettings();

    final userLat = settings.customLatitude ?? 30.0444; // Default Cairo
    final userLng = settings.customLongitude ?? 31.2357;

    final qibla = _calculateQiblaBearing(userLat, userLng);
    final location = '${settings.selectedCity}, ${settings.selectedCountry}';

    emit(state.copyWith(
      qiblaAngle: qibla,
      needleAngle: qibla,
      locationLabel: location,
      isLoading: false,
    ));
  }

  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * (math.pi / 180.0);
    final lng1 = lng * (math.pi / 180.0);
    const lat2 = _kaabaLat * (math.pi / 180.0);
    const lng2 = _kaabaLng * (math.pi / 180.0);

    final dLng = lng2 - lng1;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    var bearing = math.atan2(y, x) * (180.0 / math.pi);
    bearing = (bearing + 360.0) % 360.0;
    return bearing;
  }

  void updateHeading(double heading) {
    // Relative angle to turn needle: Qibla - heading
    final relativeAngle = (state.qiblaAngle - heading + 360.0) % 360.0;
    // Check if device is directly facing Qibla within 4 degrees tolerance
    final isFacing = relativeAngle < 4.0 || relativeAngle > 356.0;

    emit(state.copyWith(
      currentHeading: heading,
      needleAngle: relativeAngle,
      isFacingQibla: isFacing,
    ));
  }
}
