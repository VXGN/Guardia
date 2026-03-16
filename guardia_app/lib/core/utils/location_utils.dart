import 'package:geolocator/geolocator.dart';

/// Location utility functions using Geolocator.
class LocationUtils {
  LocationUtils._();

  /// Check and request location permissions using Geolocator's native flow.
  /// This correctly handles both permission and location service state.
  /// Returns `true` if permission is granted.
  static Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print('LocationUtils: Permission status before request: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('LocationUtils: Permission status after request: $permission');
    }

    if (permission == LocationPermission.deniedForever) {
      print('LocationUtils: Permission permanently denied.');
      return false;
    }

    final granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    print('LocationUtils: Permission granted = $granted');
    return granted;
  }

  /// Opens the device's location settings.
  static Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Opens the app's permission settings.
  static Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Get the current device position.
  static Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Calculate distance between two coordinates in meters.
  static double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Get a stream of the device's position.
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  /// Helper to generate a consistent dummy hazard zone for offline safe-routing testing.
  static Map<String, double> getMockHazardLocation(
    double originLat,
    double originLng,
  ) {
    return {'lat': originLat + 0.004, 'lng': originLng + 0.004};
  }
}
