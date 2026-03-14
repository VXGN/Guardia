import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guardia_app/core/constants/app_constants.dart';
import 'package:guardia_app/core/theme/app_theme.dart';
import 'package:guardia_app/di/injection_container.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardia_app/routes/app_router.dart';

/// Root widget of the Guardia application.
class GuardiaApp extends StatelessWidget {
  const GuardiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthStatusSubscriptionRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
