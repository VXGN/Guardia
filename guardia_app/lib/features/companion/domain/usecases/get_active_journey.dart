import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart';

class GetActiveJourney {
  final JourneyRepository repository;

  GetActiveJourney(this.repository);

  Future<Either<Failure, JourneySessionEntity?>> call() async {
    return await repository.getActiveJourney();
  }
}
