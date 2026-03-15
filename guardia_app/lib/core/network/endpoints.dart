class Endpoints {
  static const String baseUrl = 'https://guardia-rho.vercel.app/';
  static const String _apiPrefix = '/api';

  // Auth
  static const String authVerify = '$_apiPrefix/auth/verify';
  static const String login = '$_apiPrefix/auth/login';
  static const String register = '$_apiPrefix/auth/register';
  static const String logout = '$_apiPrefix/auth/logout';
  static const String refreshToken = '$_apiPrefix/auth/refresh';

  // User / Profile
  static const String profile = '$_apiPrefix/profile';
  static const String me = profile;

  // Trusted Contacts
  static const String trustedContacts = '$_apiPrefix/trusted-contacts';

  // Reports
  static const String reports = '$_apiPrefix/reports';
  static const String reportsMy = '$_apiPrefix/reports/my';
  static const String reportsStats = '$_apiPrefix/reports/stats';
  static String reportDetail(String id) => '$_apiPrefix/reports/$id';
  static String reportMedia(String id) => '$_apiPrefix/reports/$id/media';
  static String reportStatusLogs(String id) => '$_apiPrefix/reports/$id/logs';

  // Heatmap & Risk
  static const String heatmapData = '$_apiPrefix/risk-areas';
  static const String heatmapClusters = '$_apiPrefix/risk-areas';
  static const String areaRiskSummary = '$_apiPrefix/risk-areas';
  static const String riskScores = '$_apiPrefix/risk-areas';

  // Risk Areas (BE)
  static const String riskAreas = '$_apiPrefix/risk-areas';

  // Journey / Routing
  static const String journeys = '$_apiPrefix/journeys';
  static const String activeJourney = '$_apiPrefix/journeys/active';
  static const String safeRoute = '$_apiPrefix/route/safe';
  static String journeyLocations(String id) => '$_apiPrefix/journeys/$id/locations';
  static String finishJourney(String id) => '$_apiPrefix/journeys/$id/finish';
  static String cancelJourney(String id) => '$_apiPrefix/journeys/$id/cancel';
  static String journeyDetail(String id) => '$_apiPrefix/journeys/$id';
  static String checkJourneyStatus(String id) => '$_apiPrefix/journeys/$id/status';

  // Panic
  static const String triggerPanic = '$_apiPrefix/panic/trigger';
  static const String cancelPanic = '$_apiPrefix/panic/cancel';

  // Notifications
  static const String notifications = '$_apiPrefix/notifications';
  static const String notificationsUnreadCount =
      '$_apiPrefix/notifications/unread-count';
  static const String notificationsMarkAllRead =
      '$_apiPrefix/notifications/mark-all-read';

  // News
  static const String newsArticles = '$_apiPrefix/news/articles';
  static const String newsAreaScores = '$_apiPrefix/news/area-scores';
}
