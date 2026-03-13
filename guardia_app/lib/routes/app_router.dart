import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/home/presentation/pages/splash_page.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/login_page.dart';
import 'package:guardia_app/features/auth/presentation/pages/register_page.dart';
import 'package:guardia_app/features/home/presentation/pages/main_screen.dart';
import 'package:guardia_app/features/auth/presentation/pages/authority_login_page.dart';

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
  ],
);

