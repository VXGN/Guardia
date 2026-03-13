import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/route_option.dart';

abstract class RoutingRepository {
  Future<Either<Failure, List<RouteOption>>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  });
}
