import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class StartJourney {

  StartJourney(this.repository);
  final JourneyRepository repository;

  Future<Either<Failure, Journey>> call({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required List<String> trustedContactIds,
  }) async {
    return repository.startJourney(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      trustedContactIds: trustedContactIds,
    );
  }
}
