import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';
import 'package:guardia_app/data/models/user_model.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.storageService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String Identifier,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.login,
        data: {
          'identifier': Identifier,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data['data']);
      final token = response.data['token'] as String;

      await storageService.saveToken(token);

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error during login'));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data['data']);
      final token = response.data['token'] as String;

      await storageService.saveToken(token);

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error during registration'));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await apiClient.post(Endpoints.logout);
      await storageService.deleteToken();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final response = await apiClient.get(Endpoints.me);
      final user = UserModel.fromJson(response.data['data']);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get current user'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
