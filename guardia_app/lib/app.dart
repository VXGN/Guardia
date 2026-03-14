import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guardia_app/core/constants/app_constants.dart';
import 'package:guardia_app/core/theme/app_theme.dart';
import 'package:guardia_app/di/injection_container.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardia_app/routes/app_router.dart';

import 'package:guardia_app/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_bloc.dart';

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
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) {
                debugPrint('DEBUG: Creating AuthBloc');
                return sl<AuthBloc>()..add(AuthStatusSubscriptionRequested());
              },
              lazy: false,
            ),
            BlocProvider<ReportBloc>(
              create: (_) => sl<ReportBloc>(),
            ),
            BlocProvider<ProfileBloc>(
              create: (_) => sl<ProfileBloc>(),
            ),
            BlocProvider<TrustedContactBloc>(
              create: (_) => sl<TrustedContactBloc>(),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
