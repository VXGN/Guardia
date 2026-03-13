import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class CancelJourney {
  final JourneyRepository repository;

  CancelJourney(this.repository);

  Future<Either<Failure, Journey>> call(String id) async {
    return await repository.cancelJourney(id);
  }
}
