import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';

class GetHeatmapClusters {
  final RiskRepository repository;

  GetHeatmapClusters(this.repository);

  Future<Either<Failure, List<HeatmapCluster>>> call() async {
    return await repository.getHeatmapClusters();
  }
}
