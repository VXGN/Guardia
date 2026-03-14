import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/entities/journey_location_log.dart';

abstract class JourneyRepository {
  Future<Either<Failure, Journey>> startJourney({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required List<String> trustedContactIds,
  });

  Future<Either<Failure, Journey>> getActiveJourney();

  Future<Either<Failure, JourneyLocationLog>> updateJourneyLocation({
    required String journeyId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, Journey>> finishJourney(String id);

  Future<Either<Failure, Journey>> cancelJourney(String id);

  Future<Either<Failure, Journey>> getJourneyDetail(String id);

  Future<Either<Failure, bool>> checkInJourneyStatus(String id);
}
