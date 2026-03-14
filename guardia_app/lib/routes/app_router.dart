<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/home/presentation/pages/splash_page.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/register_page.dart';
import 'package:guardia_app/features/home/presentation/pages/main_screen.dart';
import 'package:guardia_app/features/home/presentation/pages/report_incident_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/authority_login_page.dart';
import 'package:guardia_app/features/home/presentation/pages/report_success_page.dart';
=======
﻿import 'package:go_router/go_router.dart';
import 'package:guardia_app/presentation/pages/auth/authority_login_page.dart';
import 'package:guardia_app/presentation/pages/auth/login_page.dart';
import 'package:guardia_app/presentation/pages/auth/register_page.dart';
import 'package:guardia_app/presentation/pages/home/main_screen.dart';
import 'package:guardia_app/presentation/pages/onboarding/onboarding_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_incident_page.dart';
import 'package:guardia_app/presentation/pages/reports/report_success_page.dart';
import 'package:guardia_app/presentation/pages/splash/splash_page.dart';
>>>>>>> 602ec3e (refactor: resolve analysis errors and harden type safety across repositories and presentation layer)

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
  ],
);
