import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_constants.dart';
import 'package:guardia_app/core/theme/app_theme.dart';
import 'package:guardia_app/routes/app_router.dart';

/// Root widget of the Guardia application.
class GuardiaApp extends StatelessWidget {
  const GuardiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
