/// API endpoint constants.
/// Centralized endpoint management for clean maintenance.
class Endpoints {
  Endpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User / Profile
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // Reports
  static const String reports = '/reports';
  static const String createReport = '/reports/create';
  static const String reportDetail = '/reports/'; // + {id}

  // Heatmap
  static const String heatmapData = '/heatmap/data';

  // Journey / Routing
  static const String safeRoutes = '/routes/safe';
  static const String journeyStart = '/journey/start';
  static const String journeyEnd = '/journey/end';

  // Panic
  static const String panicAlert = '/panic/alert';
  static const String emergencyContacts = '/panic/contacts';
}
