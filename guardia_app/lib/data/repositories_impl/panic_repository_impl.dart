import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/domain/repositories/panic_repository.dart';

class PanicRepositoryImpl implements PanicRepository {
  final ApiClient apiClient;

  PanicRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, void>> triggerPanic({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await apiClient.post(
        Endpoints.triggerPanic,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to trigger SOS'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelPanic() async {
    try {
      await apiClient.post(Endpoints.cancelPanic);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to cancel SOS'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
