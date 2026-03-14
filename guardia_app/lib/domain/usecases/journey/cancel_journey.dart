import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class CancelJourney {

  CancelJourney(this.repository);
  final JourneyRepository repository;

  Future<Either<Failure, Journey>> call(String id) async {
    return repository.cancelJourney(id);
  }
}
