import 'package:geolocator/geolocator.dart';

/// Location utility functions using Geolocator.
class LocationUtils {
  LocationUtils._();

  /// Check and request location permissions.
  /// Returns `true` if permission is granted.
  static Future<bool> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
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
        distanceFilter: 5, // Update every 5 meters moved
      ),
    );
  }

  /// Helper to generate a consistent dummy hazard zone for offline safe-routing testing.
  /// Given an origin, it places a hazard slightly offset so routing can simulate avoiding it.
  static Map<String, double> getMockHazardLocation(double originLat, double originLng) {
    return {
      'lat': originLat + 0.004,
      'lng': originLng + 0.004,
    };
  }
}
