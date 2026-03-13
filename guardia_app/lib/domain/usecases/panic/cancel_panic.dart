import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';

class CancelPanic {
  final PanicRepository repository;

  CancelPanic(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.cancelPanic();
  }
}
