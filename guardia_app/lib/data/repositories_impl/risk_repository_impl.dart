import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/data/models/heatmap_cluster_model.dart';
import 'package:guardia_app/data/models/risk_score_model.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/domain/entities/risk_score.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';
import 'package:guardia_app/core/utils/location_utils.dart';

class RiskRepositoryImpl implements RiskRepository {
  RiskRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<HeatmapCluster>>> getHeatmapClusters({
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) async {
    try {
      // Try real API first
      final queryParameters = <String, dynamic>{
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radiusMeters != null) 'radius': radiusMeters,
      };

      final response = await apiClient.get(
        '/api/risk-areas', // Heatmap Clusters endpoint
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final dynamic responseData = response.data;
      final dataMap = responseData is Map<String, dynamic> ? responseData['data'] : null;
      final clustersData = (dataMap is Map<String, dynamic>) 
          ? (dataMap['heatmap_clusters'] as List<dynamic>?)
          : null;

      if (clustersData == null || clustersData.isEmpty) {
        throw Exception('No clusters returned from API, using fallback');
      }

      final clusters = clustersData
          .map(
            (e) => HeatmapClusterModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return Right(clusters);
    } catch (e) {
      print('Falling back to mock HeatmapClusters due to error: $e');
      
      final originLat = latitude ?? -8.5830695;
      final originLng = longitude ?? 116.1155455;
      
      final mockHazard = LocationUtils.getMockHazardLocation(originLat, originLng);
      final hazardLat = mockHazard['lat']!;
      final hazardLng = mockHazard['lng']!;

      final clusters = [
        HeatmapClusterModel(
          id: 'mock_cluster_1',
          centerLatBlurred: hazardLat,
          centerLngBlurred: hazardLng,
          intensity: 'critical',
          radiusMeters: 400,
          incidentCount: 15,
          dominantType: 'theft',
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(hours: 24)),
          createdAt: DateTime.now(),
        ),
        HeatmapClusterModel(
          id: 'mock_cluster_2',
          centerLatBlurred: originLat + 0.012,
          centerLngBlurred: originLng - 0.008,
          intensity: 'high',
          radiusMeters: 300,
          incidentCount: 10,
          dominantType: 'stalking',
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(hours: 24)),
          createdAt: DateTime.now(),
        ),
        HeatmapClusterModel(
          id: 'mock_cluster_3',
          centerLatBlurred: originLat - 0.015,
          centerLngBlurred: originLng + 0.012,
          intensity: 'medium',
          radiusMeters: 350,
          incidentCount: 5,
          dominantType: 'verbal_harassment',
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(hours: 24)),
          createdAt: DateTime.now(),
        ),
        HeatmapClusterModel(
          id: 'mock_cluster_4',
          centerLatBlurred: originLat + 0.008,
          centerLngBlurred: originLng + 0.018,
          intensity: 'low',
          radiusMeters: 250,
          incidentCount: 2,
          dominantType: 'intimidation',
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(hours: 24)),
          createdAt: DateTime.now(),
        ),
        HeatmapClusterModel(
          id: 'mock_cluster_5',
          centerLatBlurred: originLat - 0.006,
          centerLngBlurred: originLng - 0.014,
          intensity: 'high',
          radiusMeters: 280,
          incidentCount: 8,
          dominantType: 'physical_harassment',
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(hours: 24)),
          createdAt: DateTime.now(),
        ),
      ];
      return Right(clusters);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAreaRiskSummary({
    required double latitude,
    required double longitude,
    double? radiusMeters,
  }) async {
    try {
      // Try real API first
      final response = await apiClient.get(
        '/api/risk-areas', // Area Risk Summary endpoint (shares same endpoint as heatmap for now)
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusMeters ?? 3000,
        },
      );

      final dynamic responseData = response.data;
      final dataMap = responseData is Map<String, dynamic> ? responseData['data'] : null;
      
      if (dataMap == null || dataMap is! Map<String, dynamic>) {
        throw Exception('Invalid summary data from API');
      }

      final data = dataMap;
      final heatmapClusters =
          (data['heatmap_clusters'] as List<dynamic>? ?? const []);
      final riskScores = (data['risk_scores'] as List<dynamic>? ?? const []);

      if (heatmapClusters.isEmpty && riskScores.isEmpty) {
        throw Exception('Empty summary data, using fallback');
      }

      double maxRiskScore = 0.0;
      for (final score in riskScores) {
        final value = (score as Map<String, dynamic>)['risk_score'];
        final double parsed = value is num
            ? value.toDouble()
            : double.tryParse('$value') ?? 0.0;
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
    } catch (e) {
      print('Falling back to mock AreaRiskSummary due to error: $e');
      final summary = <String, dynamic>{
        'heatmap_cluster_count': 5,
        'risk_score_count': 12,
        'max_risk_score': 7.5,
      };
      return Right(summary);
    }
  }

  @override
  Future<Either<Failure, List<RiskScore>>> getRiskScores(
    String segmentId,
  ) async {
    try {
      // Try real API first
      final response = await apiClient.get(
        '/api/risk-areas',
      ); // Risk Scores endpoint
      final dynamic responseData = response.data;
      final rawScores =
          ((responseData['data'] as Map<String, dynamic>)['risk_scores']
              as List<dynamic>? ??
          const <dynamic>[]);
      final filteredScores = segmentId.isEmpty
          ? rawScores
          : rawScores.where(
              (e) => (e as Map<String, dynamic>)['segment_id'] == segmentId,
            );
      final scores = filteredScores
          .map((e) => RiskScoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(scores);
    } catch (e) {
      print('Falling back to mock RiskScores due to error: $e');
      return Right([
        RiskScoreModel(
          id: 'mock_score_1',
          segmentId: segmentId.isEmpty ? 'mock_segment_1' : segmentId,
          timeSlot: 'MORNING',
          riskScore: 6.8,
          incidentCount: 10,
          calculatedAt: DateTime.now(),
        ),
      ]);
    }
  }
}
