import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart';

class EndJourney {
  final JourneyRepository repository;

  EndJourney(this.repository);

  Future<Either<Failure, void>> call({required String sessionId}) async {
    return await repository.endJourney(sessionId: sessionId);
  }
}
