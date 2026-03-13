import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/journey_location_log_model.dart';
import 'package:guardia_app/data/models/journey_model.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/domain/entities/journey_location_log.dart';
import 'package:guardia_app/domain/repositories/journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final ApiClient apiClient;

  JourneyRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, Journey>> startJourney({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required List<String> trustedContactIds,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.journeys,
        data: {
          'origin_lat': originLat,
          'origin_lng': originLng,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'trusted_contact_ids': trustedContactIds,
        },
      );

      final journey = JourneyModel.fromJson(response.data['data']);
      return Right(journey);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to start journey'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Journey>> getActiveJourney() async {
    try {
      final response = await apiClient.get(Endpoints.activeJourney);
      final journey = JourneyModel.fromJson(response.data['data']);
      return Right(journey);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'No active journey found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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

      final log = JourneyLocationLogModel.fromJson(response.data['data']);
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
      final journey = JourneyModel.fromJson(response.data['data']);
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
      final journey = JourneyModel.fromJson(response.data['data']);
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
      final journey = JourneyModel.fromJson(response.data['data']);
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
      return Right(response.data['data']['is_safe'] as bool);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to check journey status'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
