import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/heatmap_cluster_model.dart';
import 'package:guardia_app/data/models/risk_score_model.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/domain/entities/risk_score.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';

class RiskRepositoryImpl implements RiskRepository {

  RiskRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<HeatmapCluster>>> getHeatmapClusters() async {
    try {
      final response = await apiClient.get(Endpoints.riskAreas);
      final dynamic responseData = response.data;
      final clusters = ((responseData['data'] as Map<String, dynamic>)['heatmap_clusters']
              as List<dynamic>? ??
          const <dynamic>[])
          .map((e) => HeatmapClusterModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(clusters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load heatmap data'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAreaRiskSummary({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient.get(
        Endpoints.riskAreas,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
        },
      );
      final dynamic responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      final heatmapClusters = (data['heatmap_clusters'] as List<dynamic>? ?? const []);
      final riskScores = (data['risk_scores'] as List<dynamic>? ?? const []);

      double maxRiskScore = 0;
      for (final score in riskScores) {
        final value = (score as Map<String, dynamic>)['risk_score'];
        final parsed = value is num ? value.toDouble() : 0;
        if (parsed > maxRiskScore) {
          maxRiskScore = parsed;
        }
      }

      final summary = <String, dynamic>{
        'heatmap_cluster_count': heatmapClusters.length,
        'risk_score_count': riskScores.length,
        'max_risk_score': maxRiskScore,
      };

      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load area risk summary'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RiskScore>>> getRiskScores(String segmentId) async {
    try {
      final response = await apiClient.get(Endpoints.riskAreas);
      final dynamic responseData = response.data;
      final rawScores = ((responseData['data'] as Map<String, dynamic>)['risk_scores']
              as List<dynamic>? ??
          const <dynamic>[]);
      final filteredScores = segmentId.isEmpty
          ? rawScores
          : rawScores.where((e) => (e as Map<String, dynamic>)['segment_id'] == segmentId);
      final scores = filteredScores
          .map((e) => RiskScoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(scores);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load risk scores'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
