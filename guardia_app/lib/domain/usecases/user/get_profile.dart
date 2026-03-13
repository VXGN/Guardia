import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/user_repository.dart';

class GetProfile {
  final UserRepository repository;

  GetProfile(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getProfile();
  }
}
