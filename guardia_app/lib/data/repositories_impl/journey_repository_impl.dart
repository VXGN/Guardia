import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/journey_location_log_model.dart';
import 'package:guardia_app/data/models/journey_contact_model.dart';
import 'package:guardia_app/data/models/journey_model.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/entities/journey_location_log.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {

  JourneyRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, Journey>> startJourney({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required List<String> trustedContactIds,
  }) async {
    // Return a mock journey for a premium demonstration
    final mockJourney = JourneyModel(
      id: 'mock-123',
      userId: 'user-1',
      status: 'active',
      startedAt: DateTime.now(),
      safeArrivalConfirmed: false,
      createdAt: DateTime.now(),
      contacts: const [
        JourneyContactModel(
          id: 'jc-1',
          journeyId: 'mock-123',
          trustedContactId: 'Bapa (Emergency)',
        ),
        JourneyContactModel(
          id: 'jc-2',
          journeyId: 'mock-123',
          trustedContactId: 'Mama',
        ),
      ],
      locationLogs: const [],
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    return Right(mockJourney);
  }

  @override
  Future<Either<Failure, Journey>> getActiveJourney() async {
    // Return a mock active journey for a premium demonstration
    final mockJourney = JourneyModel(
      id: 'mock-123',
      userId: 'user-1',
      status: 'active',
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      safeArrivalConfirmed: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      contacts: const [
        JourneyContactModel(
          id: 'jc-1',
          journeyId: 'mock-123',
          trustedContactId: 'Bapa (Emergency)',
        ),
        JourneyContactModel(
          id: 'jc-2',
          journeyId: 'mock-123',
          trustedContactId: 'Mama',
        ),
      ],
      locationLogs: const [],
      originLat: -8.5830,
      originLng: 116.1155,
      destinationLat: -8.5700,
      destinationLng: 116.1200,
    );
    return Right(mockJourney);
  }

  @override
  Future<Either<Failure, JourneyLocationLog>> updateJourneyLocation({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.journeyLocations(journeyId),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final dynamic responseData = response.data;
      final log = JourneyLocationLogModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(log);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update location'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Journey>> finishJourney(String id) async {
    try {
      final response = await apiClient.post(Endpoints.finishJourney(id));
      final dynamic responseData = response.data;
      final journey = JourneyModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(journey);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to finish journey'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Journey>> cancelJourney(String id) async {
    try {
      final response = await apiClient.post(Endpoints.cancelJourney(id));
      final dynamic responseData = response.data;
      final journey = JourneyModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(journey);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to cancel journey'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Journey>> getJourneyDetail(String id) async {
    try {
      final response = await apiClient.get(Endpoints.journeyDetail(id));
      final dynamic responseData = response.data;
      final journey = JourneyModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(journey);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load journey detail'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkInJourneyStatus(String id) async {
    try {
      final response = await apiClient.get(Endpoints.checkJourneyStatus(id));
      final dynamic responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      return Right(data['is_safe'] as bool);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to check journey status'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
