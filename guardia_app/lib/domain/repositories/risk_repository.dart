import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/domain/entities/risk_score.dart';

abstract class RiskRepository {
  Future<Either<Failure, List<HeatmapCluster>>> getHeatmapClusters({
    double? latitude,
    double? longitude,
    double? radiusMeters,
  });

  Future<Either<Failure, Map<String, dynamic>>> getAreaRiskSummary({
    required double latitude,
    required double longitude,
    double? radiusMeters,
  });

  Future<Either<Failure, List<RiskScore>>> getRiskScores(String segmentId);
}
