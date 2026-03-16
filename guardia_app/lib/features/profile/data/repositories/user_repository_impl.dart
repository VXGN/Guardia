import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';
import 'package:guardia_app/features/profile/data/models/user_model.dart';
import 'package:guardia_app/features/profile/domain/entities/user.dart';
import 'package:guardia_app/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final response = await apiClient.get(Endpoints.profile);
      final dynamic responseData = response.data;
      final user = UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
      
      // Save locally
      await secureStorage.saveUserProfile(jsonEncode(user.toJson()));
      return Right(user);
    } catch (e) {
      print('Profile API failed, checking local storage: $e');
      
      // Try local storage
      final localProfileJson = await secureStorage.getUserProfile();
      if (localProfileJson != null) {
        try {
          final user = UserModel.fromJson(jsonDecode(localProfileJson) as Map<String, dynamic>);
          return Right(user);
        } catch (_) {}
      }

      print('Falling back to mock Profile');
      
      // Try to get current firebase user to make mock more realistic
      final currentUser = FirebaseAuth.instance.currentUser;

      final mockUser = UserModel(
        id: currentUser?.uid ?? 'mock_user_123',
        fullName: currentUser?.displayName ?? 'Maulana Khairuman',
        email: currentUser?.email ?? 'maulanakhairuman2004@gmail.com',
        phoneNumber: currentUser?.phoneNumber ?? '08123456789',
        role: 'USER',
        isAnonymousMode: false,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      // Save mock locally so it can be edited
      await secureStorage.saveUserProfile(jsonEncode(mockUser.toJson()));
      return Right(mockUser);
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

      // Try hitting the backend
      try {
        final response = await apiClient.put(
          Endpoints.profile,
          data: payload,
        );
        final dynamic responseData = response.data;
        final user = UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
        await secureStorage.saveUserProfile(jsonEncode(user.toJson()));
        return Right(user);
      } catch (apiError) {
        // If API fails (e.g. backend not ready), update the local profile directly
        print('Profile update API failed, updating local storage fallback: $apiError');
        final currentProfile = await secureStorage.getUserProfile();
        if (currentProfile != null) {
          final userJson = jsonDecode(currentProfile) as Map<String, dynamic>;
          final oldUser = UserModel.fromJson(userJson);
          
          final updatedUser = UserModel(
            id: oldUser.id,
            fullName: fullName ?? oldUser.fullName,
            email: oldUser.email, // email is usually readonly, or update if provided
            phoneNumber: phoneNumber ?? oldUser.phoneNumber,
            role: oldUser.role,
            isAnonymousMode: isAnonymousMode ?? oldUser.isAnonymousMode,
            isVerified: oldUser.isVerified,
            createdAt: oldUser.createdAt,
            updatedAt: DateTime.now(),
          );
          
          await secureStorage.saveUserProfile(jsonEncode(updatedUser.toJson()));
          return Right(updatedUser);
        } else {
          return Left(ServerFailure('Failed to update profile locally and remotely.'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
