class Endpoints {
  static const String baseUrl = 'https://api.guardia.app/v1'; // TODO: Update with actual URL

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Trusted Contacts
  static const String trustedContacts = '/trusted-contacts';

  // Reports
  static const String reports = '/reports';
  static String reportMedia(String id) => '/reports/$id/media';
  static String reportDetail(String id) => '/reports/$id';
  static String reportStatusLogs(String id) => '/reports/$id/status-logs';

  // Risk & Heatmap
  static const String heatmapClusters = '/heatmap/clusters';
  static const String areaRiskSummary = '/risk/summary/current-area';
  static const String riskScores = '/risk/scores';

  // Routing
  static const String safeRoute = '/routing/safe-route';

  // Journeys
  static const String journeys = '/journeys';
  static const String activeJourney = '/journeys/active';
  static String journeyDetail(String id) => '/journeys/$id';
  static String journeyLocations(String id) => '/journeys/$id/locations';
  static String finishJourney(String id) => '/journeys/$id/finish';
  static String cancelJourney(String id) => '/journeys/$id/cancel';
  static String checkJourneyStatus(String id) => '/journeys/$id/check-status';

  // Panic
  static const String triggerPanic = '/panic/trigger';
  static const String cancelPanic = '/panic/cancel';

  // Notifications
  static const String notifications = '/notifications';
}
