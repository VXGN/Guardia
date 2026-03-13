import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/risk_score.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';

abstract class RiskRepository {
  Future<Either<Failure, List<HeatmapCluster>>> getHeatmapClusters();

  Future<Either<Failure, Map<String, dynamic>>> getAreaRiskSummary({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, List<RiskScore>>> getRiskScores(String segmentId);
}
