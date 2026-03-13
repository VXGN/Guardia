import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/route_option.dart';
import 'package:guardia_app/domain/repositories/routing_repository.dart';

class GetSafeRoutes {
  final RoutingRepository repository;

  GetSafeRoutes(this.repository);

  Future<Either<Failure, List<RouteOption>>> call({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    return await repository.getSafeRoutes(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }
}
