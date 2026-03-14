import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';

class GetCurrentUser {

  GetCurrentUser(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, User>> call() async {
    return repository.getCurrentUser();
  }
}
