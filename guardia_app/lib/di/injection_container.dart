import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/auth_interceptor.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';

// Repositories
import 'package:guardia_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/journey_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/notification_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/panic_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/report_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/risk_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/routing_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/trusted_contact_repository_impl.dart';
import 'package:guardia_app/data/repositories_impl/user_repository_impl.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';
import 'package:guardia_app/domain/repositories/notification_repository.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';
import 'package:guardia_app/domain/repositories/routing_repository.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';

// UseCases - Auth
import 'package:guardia_app/domain/usecases/auth/get_current_user.dart';
import 'package:guardia_app/domain/usecases/auth/login.dart';
import 'package:guardia_app/domain/usecases/auth/logout.dart';
import 'package:guardia_app/domain/usecases/auth/register.dart';
// UseCases - Journey
import 'package:guardia_app/domain/usecases/journey/cancel_journey.dart';
import 'package:guardia_app/domain/usecases/journey/finish_journey.dart';
import 'package:guardia_app/domain/usecases/journey/get_active_journey.dart';
import 'package:guardia_app/domain/usecases/journey/start_journey.dart';
import 'package:guardia_app/domain/usecases/journey/update_journey_location.dart';
// UseCases - Notifications
import 'package:guardia_app/domain/usecases/notifications/get_notifications.dart';
// UseCases - Panic
import 'package:guardia_app/domain/usecases/panic/cancel_panic.dart';
import 'package:guardia_app/domain/usecases/panic/trigger_panic.dart';
// UseCases - Reports
import 'package:guardia_app/domain/usecases/reports/create_report.dart';
import 'package:guardia_app/domain/usecases/reports/get_my_reports.dart';
import 'package:guardia_app/domain/usecases/reports/get_report_detail.dart';
// UseCases - Risk/Routing
import 'package:guardia_app/domain/usecases/risk/get_area_risk_summary.dart';
import 'package:guardia_app/domain/usecases/risk/get_heatmap_clusters.dart';
import 'package:guardia_app/domain/usecases/routing/get_safe_routes.dart';
// UseCases - Contacts
import 'package:guardia_app/domain/usecases/trusted_contacts/add_trusted_contact.dart';
import 'package:guardia_app/domain/usecases/trusted_contacts/delete_trusted_contact.dart';
import 'package:guardia_app/domain/usecases/trusted_contacts/get_trusted_contacts.dart';
import 'package:guardia_app/domain/usecases/trusted_contacts/update_trusted_contact.dart';
// UseCases - User
import 'package:guardia_app/domain/usecases/user/get_profile.dart';
import 'package:guardia_app/domain/usecases/user/update_profile.dart';

// Blocs
import 'package:guardia_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_bloc.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_bloc.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_bloc.dart';
import 'package:guardia_app/presentation/bloc/panic/panic_bloc.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:guardia_app/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_bloc.dart';
import 'package:guardia_app/presentation/bloc/routing/routing_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
    ),
  );
  sl.registerFactory(
    () => ReportBloc(
      createReportUseCase: sl(),
      getMyReportsUseCase: sl(),
      getReportDetailUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => JourneyBloc(
      startJourneyUseCase: sl(),
      getActiveJourneyUseCase: sl(),
      updateJourneyLocationUseCase: sl(),
      finishJourneyUseCase: sl(),
      cancelJourneyUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => PanicBloc(
      triggerPanicUseCase: sl(),
      cancelPanicUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => TrustedContactBloc(
      getContactsUseCase: sl(),
      addContactUseCase: sl(),
      updateContactUseCase: sl(),
      deleteContactUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RiskBloc(
      getHeatmapUseCase: sl(),
      getRiskSummaryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RoutingBloc(
      getSafeRoutesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => CreateReport(sl()));
  sl.registerLazySingleton(() => GetMyReports(sl()));
  sl.registerLazySingleton(() => GetReportDetail(sl()));
  sl.registerLazySingleton(() => StartJourney(sl()));
  sl.registerLazySingleton(() => GetActiveJourney(sl()));
  sl.registerLazySingleton(() => UpdateJourneyLocation(sl()));
  sl.registerLazySingleton(() => FinishJourney(sl()));
  sl.registerLazySingleton(() => CancelJourney(sl()));
  sl.registerLazySingleton(() => TriggerPanic(sl()));
  sl.registerLazySingleton(() => CancelPanic(sl()));
  sl.registerLazySingleton(() => GetTrustedContacts(sl()));
  sl.registerLazySingleton(() => AddTrustedContact(sl()));
  sl.registerLazySingleton(() => UpdateTrustedContact(sl()));
  sl.registerLazySingleton(() => DeleteTrustedContact(sl()));
  sl.registerLazySingleton(() => GetHeatmapClusters(sl()));
  sl.registerLazySingleton(() => GetAreaRiskSummary(sl()));
  sl.registerLazySingleton(() => GetSafeRoutes(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => GetNotifications(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: sl(),
      storageService: sl(),
    ),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<JourneyRepository>(
    () => JourneyRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<PanicRepository>(
    () => PanicRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<TrustedContactRepository>(
    () => TrustedContactRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<RiskRepository>(
    () => RiskRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<RoutingRepository>(
    () => RoutingRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      apiClient: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton(() => ApiClient(dio: sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl()));

  // Services
  sl.registerLazySingleton(() => SecureStorageService(sl()));

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(Dio.new);

  // Add interceptor to Dio
  sl<Dio>().interceptors.add(sl<AuthInterceptor>());
}
