import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';

class Logout {

  Logout(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    return repository.logout();
  }
}
