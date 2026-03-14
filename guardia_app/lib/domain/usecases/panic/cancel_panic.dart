import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';

class CancelPanic {

  CancelPanic(this.repository);
  final PanicRepository repository;

  Future<Either<Failure, void>> call() async {
    return repository.cancelPanic();
  }
}
