import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';

class UpdateProfile {
  final UserRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call({
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isAnonymousMode,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      isAnonymousMode: isAnonymousMode,
    );
  }
}
