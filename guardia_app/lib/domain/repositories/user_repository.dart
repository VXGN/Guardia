import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isAnonymousMode,
  });
}
