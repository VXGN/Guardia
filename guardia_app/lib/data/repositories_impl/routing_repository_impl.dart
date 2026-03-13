import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/route_option_model.dart';
import 'package:guardia_app/domain/entities/route_option.dart';
import 'package:guardia_app/domain/repositories/routing_repository.dart';

class RoutingRepositoryImpl implements RoutingRepository {
  final ApiClient apiClient;

  RoutingRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<RouteOption>>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    try {
      final response = await apiClient.get(
        Endpoints.safeRoute,
        queryParameters: {
          'origin_lat': originLat,
          'origin_lng': originLng,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
        },
      );

      final routes = (response.data['data'] as List)
          .map((e) => RouteOptionModel.fromJson(e))
          .toList();
      return Right(routes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to calculate safe routes'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
