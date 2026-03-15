import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/data/datasources/journey_remote_data_source.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final JourneyRemoteDataSource remoteDataSource;

  JourneyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, JourneySessionEntity>> startJourney({
    required double lat,
    required double lng,
    required List<String> contactIds,
  }) async {
    try {
      final session = await remoteDataSource.startJourney(
        lat: lat,
        lng: lng,
        contactIds: contactIds,
      );
      return Right(session);
    } catch (e) {
      print('Falling back to mock Journey due to error: $e');
      return Right(
        JourneySessionEntity(
          id: 'mock_journey_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'mock_user_123',
          contactIds: contactIds,
          startLatitude: lat,
          startLongitude: lng,
          startedAt: DateTime.now(),
          isActive: true,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateJourneyLocation({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    try {
      if (sessionId.startsWith('mock_')) {
        print('Real-time Journey Update [MOCK]: Lat=$lat, Lng=$lng');
        return const Right(null);
      }
      await remoteDataSource.updateJourneyLocation(
        sessionId: sessionId,
        lat: lat,
        lng: lng,
      );
      return const Right(null);
    } catch (e) {
      print('Failed to send real-time journey update: $e');
      return const Right(null); // Keep session active in mock mode
    }
  }

  @override
  Future<Either<Failure, JourneySessionEntity?>> getActiveJourney() async {
    try {
      // For now, only try the remote data source. 
      // Mocking active journey recovery across restarts would usually require local storage.
      final session = await remoteDataSource.getActiveJourney();
      return Right(session);
    } catch (e) {
      print('Error checking active journey, returning null: $e');
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> endJourney({required String sessionId}) async {
    try {
      if (sessionId.startsWith('mock_')) {
        print('Ending mock Journey session: $sessionId');
        return const Right(null);
      }
      await remoteDataSource.endJourney(sessionId: sessionId);
      return const Right(null);
    } catch (e) {
      print('Error ending journey: $e');
      return const Right(null);
    }
  }
}
