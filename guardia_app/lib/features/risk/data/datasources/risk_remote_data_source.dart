import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/features/risk/data/models/risk_cell_model.dart';
import 'package:dio/dio.dart';

abstract class RiskRemoteDataSource {
  Future<List<RiskCellModel>> getRiskHeatmap({
    required String categoryFilter,
    required String timeRange,
  });
}

class RiskRemoteDataSourceImpl implements RiskRemoteDataSource {
  final ApiClient apiClient;

  RiskRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RiskCellModel>> getRiskHeatmap({
    required String categoryFilter,
    required String timeRange,
  }) async {
    try {
      final response = await apiClient.get(
        '/risk/heatmap',
        queryParameters: {
          'category': categoryFilter,
          'range': timeRange,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => RiskCellModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}
