import 'package:get_it/get_it.dart';
import 'package:guardia_app/core/network/api_client.dart';

/// Global GetIt instance for dependency injection.
final GetIt sl = GetIt.instance;

/// Initialize all dependencies.
/// Called once at app startup before runApp().
Future<void> init() async {
  //
  // ─── Core ────────────────────────────────────────────────────────
  //

  // Network
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  //
  // ─── Features ────────────────────────────────────────────────────
  //

  // TODO: Register feature dependencies here as they are implemented.
  //
  // Example pattern for a feature:
  //
  // // BLoC
  // sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  //
  // // Use Cases
  // sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  //
  // // Repositories
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(remoteDataSource: sl()),
  // );
  //
  // // Data Sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(client: sl()),
  // );
}
