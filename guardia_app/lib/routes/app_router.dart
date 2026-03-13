import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/home/presentation/pages/splash_page.dart';
import 'package:guardia_app/features/onboarding/presentation/pages/onboarding_page.dart';

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
    // TODO: Add routes as features are implemented
    // GoRoute(
    //   path: '/login',
    //   name: 'login',
    //   builder: (context, state) => const LoginPage(),
    // ),
    // GoRoute(
    //   path: '/home',
    //   name: 'home',
    //   builder: (context, state) => const HomePage(),
    // ),
  ],
);
