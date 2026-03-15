import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';

class GetHeatmapClusters {

  GetHeatmapClusters(this.repository);
  final RiskRepository repository;

  Future<Either<Failure, List<HeatmapCluster>>> call({
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) async {
    return repository.getHeatmapClusters(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }
}
