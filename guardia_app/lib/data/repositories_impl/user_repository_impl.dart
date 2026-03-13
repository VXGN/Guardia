import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/user_model.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient apiClient;

  UserRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final response = await apiClient.get(Endpoints.me);
      final user = UserModel.fromJson(response.data['data']);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isAnonymousMode,
  }) async {
    try {
      final response = await apiClient.put(
        Endpoints.me,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (isAnonymousMode != null) 'is_anonymous_mode': isAnonymousMode,
        },
      );

      final user = UserModel.fromJson(response.data['data']);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
