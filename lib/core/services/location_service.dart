import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/app_logger.dart';

class LocationDataResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? errorMessage;

  const LocationDataResult({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.errorMessage,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Requests permissions and retrieves the user's current GPS position and city/country.
  Future<LocationDataResult> determineCurrentLocation() async {
    try {
      // 1. Check if location services are enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Location services are disabled on device.');
        return const LocationDataResult(
          isSuccess: false,
          errorMessage: 'خدمة تحديد الموقع (GPS) مغلقة. يرجى تفعيلها من إعدادات الهاتف.',
        );
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warning('Location permissions are denied by user.');
          return const LocationDataResult(
            isSuccess: false,
            errorMessage: 'تم رفض إذن تحديد الموقع. يرجى منح الإذن لضبط المواقيت تلقائياً.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('Location permissions are permanently denied.');
        return const LocationDataResult(
          isSuccess: false,
          errorMessage: 'تم رفض إذن الموقع بشكل دائم. يمكنك تفعيله يدوياً من إعدادات التطبيق في الهاتف.',
        );
      }

      // 3. Get current position with a timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      String detectedCity = 'Unknown';
      String detectedCountry = 'Unknown';

      // 4. Reverse geocode to get human-readable city & country
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          detectedCity = (place.locality?.isNotEmpty ?? false)
              ? place.locality!
              : ((place.subAdministrativeArea?.isNotEmpty ?? false)
                  ? place.subAdministrativeArea!
                  : (place.administrativeArea ?? 'Unknown'));
          detectedCountry = place.country ?? 'Unknown';
        }
      } catch (e) {
        AppLogger.warning('Reverse geocoding failed (using coordinates directly): $e');
      }

      AppLogger.info('📍 [LocationService] Detected: $detectedCity, $detectedCountry (${position.latitude}, ${position.longitude})');

      return LocationDataResult(
        isSuccess: true,
        latitude: position.latitude,
        longitude: position.longitude,
        city: detectedCity,
        country: detectedCountry,
      );
    } catch (e) {
      AppLogger.error('Failed to get location: $e');
      String friendlyMessage = 'تعذر تحديد الموقع بدقة.';
      if (e.toString().contains('MissingPluginException')) {
        friendlyMessage = 'يرجى إعادة تشغيل التطبيق بالكامل (Full Restart) لتفعيل خدمة الموقع.';
      }
      return LocationDataResult(
        isSuccess: false,
        errorMessage: friendlyMessage,
      );
    }
  }
}
