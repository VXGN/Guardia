import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/route_option_model.dart';
import 'package:guardia_app/domain/entities/route_option.dart';
import 'package:guardia_app/domain/repositories/routing_repository.dart';

class RoutingRepositoryImpl implements RoutingRepository {

  RoutingRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<RouteOption>>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.safeRoute,
        data: {
          'start_lat': originLat,
          'start_lng': originLng,
          'end_lat': destinationLat,
          'end_lng': destinationLng,
        },
      );

      final dynamic responseData = response.data;
      final routeData = responseData['data'] as Map<String, dynamic>;
      final points = (routeData['route'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final polyline = points
          .map((p) => '${p['lat']},${p['lng']}')
          .join(';');

      final routes = [
        RouteOptionModel(
          id: 'safe_route',
          polyline: polyline,
          distanceMeters: (routeData['total_distance_meters'] as num?)?.round() ?? 0,
          durationSeconds:
              (routeData['estimated_duration_seconds'] as num?)?.round() ?? 0,
          safetyScore: (routeData['total_risk_score'] as num?)?.toDouble() ?? 0,
          label: 'Recommended Safe Route',
        ),
      ];
      return Right(routes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to calculate safe routes'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
