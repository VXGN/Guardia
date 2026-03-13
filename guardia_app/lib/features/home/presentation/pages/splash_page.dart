import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

/// Splash screen — shows logo then navigates to onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding after a 2-second delay.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.goNamed('onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset('assets/images/logo.png', width: 100, height: 100),
      ),
    );
  }
}
