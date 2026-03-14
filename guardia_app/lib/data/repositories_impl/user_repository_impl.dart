import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/user_model.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final response = await apiClient.get(Endpoints.me);
      final dynamic responseData = response.data;
      final user = UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
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
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'is_anonymous_mode': isAnonymousMode,
        },
      );

      final dynamic responseData = response.data;
      final user = UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
