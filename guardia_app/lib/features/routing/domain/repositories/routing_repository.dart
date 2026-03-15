import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';

abstract class RoutingRepository {
  Future<List<RouteOptionEntity>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}
