import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardia_app/di/injection_container.dart';

/// Splash screen â€” shows the Guardia logo centered on Midnight Indigo
/// background, then auto-navigates to onboarding after 2.5 seconds.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start auth subscription if not already done (it's done in app.dart)
  }

  void _handleNavigation(BuildContext context, AuthState state) async {
    // Small delay to show brand logo
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final prefs = sl<SharedPreferences>();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      context.goNamed('onboarding');
      return;
    }

    if (state.status == AuthStatus.authenticated) {
      context.goNamed('home');
    } else if (state.status == AuthStatus.unauthenticated || state.status == AuthStatus.failure) {
      context.goNamed('login');
    }
    // If still loading or unknown, do nothing and wait for next state change
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status != AuthStatus.unknown && current.status != AuthStatus.loading,
      listener: _handleNavigation,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: SvgPicture.asset(
            'assets/logo/icon_guardia_navy.svg',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
