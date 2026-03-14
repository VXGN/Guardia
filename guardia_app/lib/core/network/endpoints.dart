class Endpoints {
  static const String baseUrl = 'https://api.guardia.app/api/v1/'; // Updated to include /api/ prefix

  // Auth
  static const String authVerify = '/auth/verify';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User / Profile
  static const String profile = '/profile';
  static const String me = '/auth/me';

  // Trusted Contacts
  static const String trustedContacts = '/trusted-contacts';

  // Reports
  static const String reports = '/reports';
  static const String reportsMy = '/reports/my';
  static const String reportsStats = '/reports/stats';
  static String reportDetail(String id) => '/reports/$id';
  static String reportMedia(String id) => '/reports/$id/media';
  static String reportStatusLogs(String id) => '/reports/$id/logs';

  // Heatmap & Risk
  static const String heatmapData = '/heatmap';
  static const String heatmapClusters = '/heatmap/clusters';
  static const String areaRiskSummary = '/risk/summary';
  static const String riskScores = '/risk/scores';

  // Risk Areas (BE)
  static const String riskAreas = '/risk-areas';

  // Journey / Routing
  static const String journeys = '/journeys';
  static const String activeJourney = '/journeys/active';
  static const String safeRoute = '/route/safe';
  static String journeyLocations(String id) => '/journeys/$id/locations';
  static String finishJourney(String id) => '/journeys/$id/finish';
  static String cancelJourney(String id) => '/journeys/$id/cancel';
  static String journeyDetail(String id) => '/journeys/$id';
  static String checkJourneyStatus(String id) => '/journeys/$id/status';

  // Panic
  static const String triggerPanic = '/panic/trigger';
  static const String cancelPanic = '/panic/cancel';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // News
  static const String newsArticles = '/news/articles';
  static const String newsAreaScores = '/news/area-scores';
}
