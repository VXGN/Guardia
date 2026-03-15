import 'package:guardia_app/features/risk/domain/entities/risk_cell_entity.dart';
import 'package:guardia_app/features/risk/domain/repositories/risk_repository.dart';

class GetRiskHeatmap {
  final RiskRepository repository;

  GetRiskHeatmap(this.repository);

  Future<List<RiskCellEntity>> call({
    required String categoryFilter,
    required String timeRange,
  }) {
    return repository.getRiskHeatmap(
      categoryFilter: categoryFilter,
      timeRange: timeRange,
    );
  }
}
