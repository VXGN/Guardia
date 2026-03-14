import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';

abstract class PanicRepository {
  Future<Either<Failure, void>> triggerPanic({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> cancelPanic();
}
