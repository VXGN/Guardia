import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class GetActiveJourney {
  final JourneyRepository repository;

  GetActiveJourney(this.repository);

  Future<Either<Failure, Journey>> call() async {
    return await repository.getActiveJourney();
  }
}
