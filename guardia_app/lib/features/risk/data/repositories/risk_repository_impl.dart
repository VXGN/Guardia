import 'package:guardia_app/features/risk/data/datasources/risk_remote_data_source.dart';
import 'package:guardia_app/features/risk/domain/entities/risk_cell_entity.dart';
import 'package:guardia_app/features/risk/domain/repositories/risk_repository.dart';

class RiskRepositoryImpl implements RiskRepository {
  final RiskRemoteDataSource remoteDataSource;

  RiskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RiskCellEntity>> getRiskHeatmap({
    required String categoryFilter,
    required String timeRange,
  }) async {
    try {
      final models = await remoteDataSource.getRiskHeatmap(
        categoryFilter: categoryFilter,
        timeRange: timeRange,
      );
      return models; // RiskCellModel extends RiskCellEntity
    } catch (e) {
      // In a real app we would map this to Domain exceptions
      rethrow;
    }
  }
}
