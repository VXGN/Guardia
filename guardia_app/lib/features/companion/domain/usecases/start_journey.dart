import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart';

class StartJourney {
  final JourneyRepository repository;

  StartJourney(this.repository);

  Future<Either<Failure, JourneySessionEntity>> call({
    required double lat,
    required double lng,
    required List<String> contactIds,
  }) async {
    return await repository.startJourney(
      lat: lat,
      lng: lng,
      contactIds: contactIds,
    );
  }
}
