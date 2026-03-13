/// Application configuration constants.
class AppConfig {
  AppConfig._();

  // Environment
  static const String environment = 'development';

  // API
  static const String baseUrl = 'https://api.guardia.app';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Firebase
  static const String firebaseProjectId = 'guardia-app-ec59e';

  // Maps
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;
  static const double defaultZoom = 14;
}
