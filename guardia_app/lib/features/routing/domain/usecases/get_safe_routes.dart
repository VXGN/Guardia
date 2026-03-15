import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';
import 'package:guardia_app/features/routing/domain/repositories/routing_repository.dart';

class GetSafeRoutes {
  final RoutingRepository repository;

  GetSafeRoutes(this.repository);

  Future<List<RouteOptionEntity>> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return repository.getSafeRoutes(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}
