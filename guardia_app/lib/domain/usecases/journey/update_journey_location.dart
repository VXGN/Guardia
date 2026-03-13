import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey_location_log.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class UpdateJourneyLocation {
  final JourneyRepository repository;

  UpdateJourneyLocation(this.repository);

  Future<Either<Failure, JourneyLocationLog>> call({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    return await repository.updateJourneyLocation(
      journeyId: journeyId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
