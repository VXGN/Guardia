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

  // Trusted Contacts
  static const String trustedContacts = '/trusted-contacts';

  // Reports (BE handles CRUD)
  static const String reports = '/reports';
  static const String reportsMy = '/reports/my';
  static const String reportsStats = '/reports/stats';

  // Heatmap (AI Service)
  static const String heatmapData = '/heatmap';

  // Risk Areas (BE)
  static const String riskAreas = '/risk-areas';

  // Journey / Routing (AI Service)
  static const String safeRoute = '/route/safe';
  static const String journeyStart = '/journey/start';
  static const String journeyUpdate = '/journey/update';
  static const String journeyStop = '/journey/stop';

  // Risk Analysis (BE proxies to AI)
  static const String analyzeRisk = '/analysis/risk';

  // Panic
  static const String panicTrigger = '/panic/trigger';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // News (AI Service)
  static const String newsArticles = '/news/articles';
  static const String newsAreaScores = '/news/area-scores';
}
