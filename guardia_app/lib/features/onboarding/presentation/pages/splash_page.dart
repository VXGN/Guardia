import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/core/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardia_app/di/injection_container.dart';

/// Splash screen — shows the Guardia logo centered on Midnight Indigo
/// background, then auto-navigates to onboarding after 2.5 seconds.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 4), () async {
      if (!mounted || _didNavigate) return;

      final authState = context.read<AuthBloc>().state;
      if (authState.status != AuthStatus.unknown &&
          authState.status != AuthStatus.loading) {
        return;
      }

      final prefs = sl<SharedPreferences>();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      _didNavigate = true;
      if (hasSeenOnboarding) {
        context.goNamed('login');
      } else {
        context.goNamed('onboarding');
      }
    });
  }

  void _handleNavigation(BuildContext context, AuthState state) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final prefs = sl<SharedPreferences>();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      _didNavigate = true;
      context.goNamed('onboarding');
      return;
    }

    if (state.status == AuthStatus.authenticated) {
      final hasPermissions = await sl<PermissionService>().hasAllPermissions();
      if (mounted) {
        _didNavigate = true;
        if (hasPermissions) {
          context.goNamed('home');
        } else {
          context.goNamed('permissions');
        }
      }
    } else if (state.status == AuthStatus.unauthenticated || state.status == AuthStatus.failure) {
      _didNavigate = true;
      context.goNamed('login');
    }
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
