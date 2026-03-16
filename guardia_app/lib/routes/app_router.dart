import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/auth/presentation/pages/authority_login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/register_page.dart';
import 'package:guardia_app/presentation/pages/home/main_screen.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/permission_request_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_incident_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_success_page.dart';
import 'package:guardia_app/presentation/pages/reports/my_reports_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_detail_page.dart';
import 'package:guardia_app/features/reports/domain/entities/report_entity.dart';
import 'package:guardia_app/features/profile/presentation/pages/impact_dashboard_page.dart';
import 'package:guardia_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/splash_page.dart';
import 'package:guardia_app/presentation/pages/journey/active_journey_page.dart';
import 'package:guardia_app/presentation/pages/contacts/trusted_contacts_page.dart';
import 'package:guardia_app/features/profile/presentation/pages/profile_page.dart';
import 'package:guardia_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:guardia_app/presentation/pages/journey/companion_chat_page.dart';
import 'package:guardia_app/presentation/pages/journey/companion_call_page.dart';
import 'package:guardia_app/features/profile/presentation/pages/policy_page.dart';



/// GoRouter instance for Guardia app navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
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
      path: '/permissions',
      name: 'permissions',
      builder: (context, state) => const PermissionRequestPage(),
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
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'edit_profile',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: 'privacy_policy',
          name: 'privacy_policy',
          builder: (context, state) => const PolicyPage(),
        ),
      ],
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
      path: '/report_success',
      name: 'report_success',
      builder: (context, state) => const ReportSuccessPage(),
    ),
    GoRoute(
      path: '/report_incident',
      name: 'report_incident',
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
      routes: [
        GoRoute(
          name: 'report_detail',
          path: 'report_detail',
          builder: (context, state) {
            final report = state.extra as ReportEntity;
            return ReportDetailPage(report: report);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/companion_chat/:companionId',
      name: 'companion_chat',
      builder: (context, state) {
        final id = state.pathParameters['companionId'] ?? '1';
        return CompanionChatPage(companionId: id);
      },
    ),
    GoRoute(
      path: '/companion_call/:companionId',
      name: 'companion_call',
      builder: (context, state) {
        final id = state.pathParameters['companionId'] ?? '1';
        return CompanionCallPage(companionId: id);
      },
    ),
  ],
);
