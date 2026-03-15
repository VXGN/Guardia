import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_constants.dart';
import 'package:guardia_app/core/theme/app_theme.dart';
import 'package:guardia_app/di/injection_container.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';
import 'package:guardia_app/features/panic/presentation/bloc/panic/panic_bloc.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_bloc.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_bloc.dart';
import 'package:guardia_app/presentation/bloc/routing/routing_bloc.dart';
import 'package:guardia_app/routes/app_router.dart';

class GuardiaApp extends StatelessWidget {
  const GuardiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthStatusSubscriptionRequested())),
        BlocProvider(create: (_) => sl<CompanionBloc>()..add(const CompanionStarted())),
        BlocProvider(create: (_) => sl<ReportBloc>()),
        BlocProvider(create: (_) => sl<PanicBloc>()),
        BlocProvider(create: (_) => sl<RiskBloc>()),
        BlocProvider(create: (_) => sl<RoutingBloc>()),
        BlocProvider(create: (_) => sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<NotificationBloc>()),
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
