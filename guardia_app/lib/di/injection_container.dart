import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/auth_interceptor.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';
import 'package:guardia_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';
import 'package:guardia_app/domain/usecases/auth/login.dart';

final sl = GetIt.instance;

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

  // Core
  sl.registerLazySingleton(() => ApiClient(dio: sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl()));

  // Services
  sl.registerLazySingleton(() => SecureStorageService(sl()));

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Dio());

  // Add interceptor to Dio
  sl<Dio>().interceptors.add(sl<AuthInterceptor>());
}
