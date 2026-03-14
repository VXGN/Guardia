import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/route_option.dart';
import 'package:guardia_app/domain/repositories/routing_repository.dart';

class GetSafeRoutes {

  GetSafeRoutes(this.repository);
  final RoutingRepository repository;

  Future<Either<Failure, List<RouteOption>>> call({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    return repository.getSafeRoutes(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }
}
