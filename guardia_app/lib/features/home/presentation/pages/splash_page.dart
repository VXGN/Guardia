import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
