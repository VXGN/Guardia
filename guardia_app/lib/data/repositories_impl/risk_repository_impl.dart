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
      final response = await apiClient.get(Endpoints.heatmapClusters);
      final dynamic responseData = response.data;
      final clusters = (responseData['data'] as List)
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
        Endpoints.areaRiskSummary,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final dynamic responseData = response.data;
      return Right(responseData['data'] as Map<String, dynamic>);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load area risk summary'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RiskScore>>> getRiskScores(String segmentId) async {
    try {
      final response = await apiClient.get(
        Endpoints.riskScores,
        queryParameters: {'segment_id': segmentId},
      );
      final dynamic responseData = response.data;
      final scores = (responseData['data'] as List)
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
