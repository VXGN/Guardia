import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';

class TriggerPanic {
  final PanicRepository repository;

  TriggerPanic(this.repository);

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
  }) async {
    return await repository.triggerPanic(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
