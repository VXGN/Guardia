import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/auth_interceptor.dart';
import 'package:guardia_app/core/services/panic_alert_service.dart';
import 'package:guardia_app/core/services/permission_service.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';

// Features - Companion
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart' as companion_repo;
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart' as companion_repo_contact;
import 'package:guardia_app/features/companion/data/repositories/journey_repository_impl.dart' as companion_impl;
import 'package:guardia_app/features/companion/data/repositories/trusted_contact_repository_impl.dart' as companion_impl_contact;
import 'package:guardia_app/features/companion/data/datasources/journey_remote_data_source.dart';
import 'package:guardia_app/features/companion/data/datasources/trusted_contact_local_data_source.dart';
import 'package:guardia_app/features/companion/domain/usecases/get_trusted_contacts.dart' as companion_uc;
import 'package:guardia_app/features/companion/domain/usecases/add_trusted_contact.dart' as companion_uc_add;
import 'package:guardia_app/features/companion/domain/usecases/update_trusted_contact.dart' as companion_uc_update;
import 'package:guardia_app/features/companion/domain/usecases/delete_trusted_contact.dart' as companion_uc_delete;
import 'package:guardia_app/features/companion/domain/usecases/start_journey.dart' as companion_uc_start;
import 'package:guardia_app/features/companion/domain/usecases/update_journey_location.dart' as companion_uc_loc;
import 'package:guardia_app/features/companion/domain/usecases/get_active_journey.dart' as companion_uc_active;
import 'package:guardia_app/features/companion/domain/usecases/end_journey.dart' as companion_uc_end;
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';

// Features - Auth
import 'package:guardia_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardia_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:guardia_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';

// Features - Panic
import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';
import 'package:guardia_app/features/panic/data/repositories/panic_repository_impl.dart';
import 'package:guardia_app/features/panic/data/datasources/panic_remote_data_source.dart';
import 'package:guardia_app/features/panic/domain/usecases/start_panic.dart';
import 'package:guardia_app/features/panic/domain/usecases/update_panic_location.dart';
import 'package:guardia_app/features/panic/domain/usecases/cancel_panic.dart';
import 'package:guardia_app/features/panic/presentation/bloc/panic/panic_bloc.dart';

// Features - Reports
import 'package:guardia_app/features/reports/domain/repositories/report_repository.dart';
import 'package:guardia_app/features/reports/data/repositories/report_repository_impl.dart';
import 'package:guardia_app/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:guardia_app/features/reports/domain/usecases/create_report.dart';
import 'package:guardia_app/features/reports/domain/usecases/get_my_reports.dart';
import 'package:guardia_app/features/reports/domain/usecases/get_all_reports.dart';
import 'package:guardia_app/features/reports/domain/usecases/get_report_detail.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_bloc.dart';

// Features - Other (Core/Old Structure)
import 'package:guardia_app/data/repositories_impl/notification_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/user_repository_impl.dart';
import 'package:guardia_app/domain/repositories/notification_repository.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';
import 'package:guardia_app/domain/usecases/notifications/get_notifications.dart';
import 'package:guardia_app/domain/usecases/user/get_profile.dart';
import 'package:guardia_app/domain/usecases/user/update_profile.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_bloc.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:guardia_app/data/repositories_impl/risk_repository_impl.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';
import 'package:guardia_app/domain/usecases/risk/get_area_risk_summary.dart';
import 'package:guardia_app/domain/usecases/risk/get_heatmap_clusters.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_bloc.dart';

// Features - Risk (New)
import 'package:guardia_app/features/risk/domain/repositories/risk_repository.dart' as new_risk_repo;
import 'package:guardia_app/features/risk/data/repositories/risk_repository_impl.dart' as new_risk_repo_impl;
import 'package:guardia_app/features/risk/data/datasources/risk_remote_data_source.dart';
import 'package:guardia_app/features/risk/domain/usecases/get_risk_heatmap.dart';
import 'package:guardia_app/features/risk/presentation/bloc/risk/risk_bloc.dart' as new_risk_bloc;

// Features - Routing (New)
import 'package:guardia_app/features/routing/domain/repositories/routing_repository.dart' as new_routing_repo;
import 'package:guardia_app/features/routing/data/repositories/routing_repository_impl.dart' as new_routing_repo_impl;
import 'package:guardia_app/features/routing/data/datasources/routing_remote_data_source.dart';
import 'package:guardia_app/features/routing/domain/usecases/get_safe_routes.dart' as new_routing_uc;
import 'package:guardia_app/features/routing/domain/usecases/start_navigation.dart';
import 'package:guardia_app/features/routing/domain/usecases/stop_navigation.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_bloc.dart' as new_routing_bloc;


import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GetIt sl = GetIt.instance;

const String _defaultGoogleWebClientId =
    '57902038315-uhgpi18btugbk0u2hajt8o3sq2rnve5a.apps.googleusercontent.com';

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(Dio.new);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() {
    final webClientId = const String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: _defaultGoogleWebClientId,
    );

    if (kIsWeb) {
      return GoogleSignIn(clientId: webClientId);
    }

    return GoogleSignIn();
  });

  // Features - Companion
  sl.registerFactory(
    () => CompanionBloc(
      getTrustedContacts: sl(),
      addTrustedContact: sl(),
      updateTrustedContact: sl(),
      deleteTrustedContact: sl(),
      startJourney: sl(),
      updateJourneyLocation: sl(),
      endJourney: sl(),
      getActiveJourney: sl(),
    ),
  );

  sl.registerLazySingleton(() => companion_uc_start.StartJourney(sl()));
  sl.registerLazySingleton(() => companion_uc_active.GetActiveJourney(sl()));
  sl.registerLazySingleton(() => companion_uc_loc.UpdateJourneyLocation(sl()));
  sl.registerLazySingleton(() => companion_uc_end.EndJourney(sl()));
  sl.registerLazySingleton(() => companion_uc.GetTrustedContacts(sl()));
  sl.registerLazySingleton(() => companion_uc_add.AddTrustedContact(sl()));
  sl.registerLazySingleton(() => companion_uc_update.UpdateTrustedContact(sl()));
  sl.registerLazySingleton(() => companion_uc_delete.DeleteTrustedContact(sl()));

  sl.registerLazySingleton<companion_repo.JourneyRepository>(
    () => companion_impl.JourneyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<companion_repo_contact.TrustedContactRepository>(
    () => companion_impl_contact.TrustedContactRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<JourneyRemoteDataSource>(
    () => JourneyRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TrustedContactLocalDataSource>(
    () => TrustedContactLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Features - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(sl(), sl()),
  );

  // Features - Panic
  sl.registerFactory(
    () => PanicBloc(
      startPanicUseCase: sl(),
      updatePanicLocationUseCase: sl(),
      cancelPanicUseCase: sl(),
      panicAlertService: sl(),
    ),
  );
  sl.registerLazySingleton(() => StartPanic(sl()));
  sl.registerLazySingleton(() => UpdatePanicLocation(sl()));
  sl.registerLazySingleton(() => CancelPanicAction(sl()));
  sl.registerLazySingleton<PanicRepository>(
    () => PanicRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PanicRemoteDataSource>(
    () => PanicRemoteDataSource(apiClient: sl()),
  );

  // Features - Reports
  sl.registerFactory(
    () => ReportBloc(
      createReport: sl(),
      getMyReports: sl(),
      getAllReports: sl(),
      getReportDetail: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateReport(sl()));
  sl.registerLazySingleton(() => GetMyReports(sl()));
  sl.registerLazySingleton(() => GetAllReports(sl()));
  sl.registerLazySingleton(() => GetReportDetail(sl()));
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()));
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Other
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RiskBloc(
      getHeatmapUseCase: sl(),
      getRiskSummaryUseCase: sl(),
    ),
  );
  sl.registerFactory(() => NotificationBloc(getNotificationsUseCase: sl()));

  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => GetHeatmapClusters(sl()));
  sl.registerLazySingleton(() => GetAreaRiskSummary(sl()));
  sl.registerLazySingleton(() => GetNotifications(sl()));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(apiClient: sl()));
  sl.registerLazySingleton<RiskRepository>(() => RiskRepositoryImpl(apiClient: sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(apiClient: sl()),
  );

  // Services & Core
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => PermissionService());
  sl.registerLazySingleton(() => ApiClient(dio: sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl<FirebaseAuth>(), sl<Dio>()));

  // Features - Risk (New DI)
  sl.registerFactory(() => new_risk_bloc.RiskBloc(getRiskHeatmap: sl()));
  sl.registerLazySingleton(() => GetRiskHeatmap(sl()));
  sl.registerLazySingleton<new_risk_repo.RiskRepository>(() => new_risk_repo_impl.RiskRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RiskRemoteDataSource>(() => RiskRemoteDataSourceImpl(apiClient: sl()));

  // Features - Routing (New DI)
  sl.registerFactory(() => new_routing_bloc.RoutingBloc(getSafeRoutes: sl(), startNavigation: sl(), stopNavigation: sl()));
  sl.registerLazySingleton(() => new_routing_uc.GetSafeRoutes(sl()));
  sl.registerLazySingleton(() => StartNavigation());
  sl.registerLazySingleton(() => StopNavigation());
  sl.registerLazySingleton<new_routing_repo.RoutingRepository>(() => new_routing_repo_impl.RoutingRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RoutingRemoteDataSource>(() => RoutingRemoteDataSourceImpl(apiClient: sl()));

  sl.registerLazySingleton(() => PanicAlertService());
  sl<Dio>().interceptors.add(sl<AuthInterceptor>());
}
