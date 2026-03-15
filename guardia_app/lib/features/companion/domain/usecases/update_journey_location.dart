import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart';

class UpdateJourneyLocation {
  final JourneyRepository repository;

  UpdateJourneyLocation(this.repository);

  Future<Either<Failure, void>> call({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    return await repository.updateJourneyLocation(
      sessionId: sessionId,
      lat: lat,
      lng: lng,
    );
  }
}
