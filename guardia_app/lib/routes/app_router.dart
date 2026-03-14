import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/auth/presentation/pages/authority_login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/register_page.dart';
import 'package:guardia_app/presentation/pages/home/main_screen.dart';
import 'package:guardia_app/presentation/pages/onboarding/onboarding_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_incident_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_success_page.dart';
import 'package:guardia_app/presentation/pages/reports/my_reports_page.dart';
import 'package:guardia_app/presentation/pages/profile/impact_dashboard_page.dart';
import 'package:guardia_app/presentation/pages/profile/notifications_page.dart';
import 'package:guardia_app/presentation/pages/journey/active_journey_page.dart';
import 'package:guardia_app/presentation/pages/contacts/trusted_contacts_page.dart';
import 'package:guardia_app/presentation/pages/splash/splash_page.dart';


/// GoRouter instance for Guardia app navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/authority-login',
      name: 'authority-login',
      builder: (context, state) => const AuthorityLoginPage(),
    ),
    GoRoute(
      path: '/report-success',
      name: 'report-success',
      builder: (context, state) => const ReportSuccessPage(),
    ),
    GoRoute(
      path: '/report',
      name: 'report',
      builder: (context, state) => const ReportIncidentPage(),
    ),
    GoRoute(
      path: '/impact_dashboard',
      name: 'impact_dashboard',
      builder: (context, state) => const ImpactDashboardPage(),
    ),
    GoRoute(
      path: '/my_reports',
      name: 'my_reports',
      builder: (context, state) => const MyReportsPage(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/active_journey',
      name: 'active_journey',
      builder: (context, state) => const ActiveJourneyPage(),
    ),
    GoRoute(
      path: '/trusted_contacts',
      name: 'trusted_contacts',
      builder: (context, state) => const TrustedContactsPage(),
    ),
  ],
);
