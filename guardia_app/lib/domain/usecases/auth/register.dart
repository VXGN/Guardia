import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/user.dart';
import 'package:guardia_app/domain/repositories/auth_repository.dart';

class Register {

  Register(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, User>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return repository.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
