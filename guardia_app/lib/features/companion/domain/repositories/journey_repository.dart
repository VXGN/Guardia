import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';

abstract class JourneyRepository {
  Future<Either<Failure, JourneySessionEntity>> startJourney({
    required double lat,
    required double lng,
    required List<String> contactIds,
  });

  Future<Either<Failure, void>> updateJourneyLocation({
    required String sessionId,
    required double lat,
    required double lng,
  });

  Future<Either<Failure, JourneySessionEntity?>> getActiveJourney();

  Future<Either<Failure, void>> endJourney({required String sessionId});
}
