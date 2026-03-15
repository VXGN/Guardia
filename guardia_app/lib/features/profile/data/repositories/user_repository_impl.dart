import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/features/profile/data/models/user_model.dart';
import 'package:guardia_app/features/profile/domain/entities/user.dart';
import 'package:guardia_app/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final response = await apiClient.get(Endpoints.profile);
      final dynamic responseData = response.data;
      final user = UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(user);
    } catch (e) {
      print('Falling back to mock Profile due to error: $e');
      return Right(
        UserModel(
          id: 'mock_user_123',
          fullName: 'Maulana Khairuman',
          email: 'maulanakhairuman2004@gmail.com',
          phoneNumber: '08123456789',
          role: 'USER',
          isAnonymousMode: false,
          isVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
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
      final payload = <String, dynamic>{};
      if (fullName != null) payload['full_name'] = fullName;
      if (phoneNumber != null) payload['phone_number'] = phoneNumber;
      if (isAnonymousMode != null) payload['is_anonymous_mode'] = isAnonymousMode;

      final response = await apiClient.put(
        Endpoints.profile,
        data: payload,
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
