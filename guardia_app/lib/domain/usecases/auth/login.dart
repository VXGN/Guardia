import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';

class Login {

  Login(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, User>> call({
    required String identifier,
    required String password,
  }) async {
    return repository.login(
      identifier: identifier,
      password: password,
    );
  }
}
