import 'package:guardia_app/features/routing/data/datasources/routing_remote_data_source.dart';
import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';
import 'package:guardia_app/features/routing/domain/repositories/routing_repository.dart';

class RoutingRepositoryImpl implements RoutingRepository {
  final RoutingRemoteDataSource remoteDataSource;

  RoutingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RouteOptionEntity>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final models = await remoteDataSource.getSafeRoutes(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      return models; // RouteOptionModel extends RouteOptionEntity
    } catch (e) {
      rethrow;
    }
  }
}
