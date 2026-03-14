import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';

class TriggerPanic {

  TriggerPanic(this.repository);
  final PanicRepository repository;

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
  }) async {
    return repository.triggerPanic(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
