import 'package:guardia_app/features/risk/domain/entities/risk_cell_entity.dart';

abstract class RiskRepository {
  Future<List<RiskCellEntity>> getRiskHeatmap({
    required String categoryFilter,
    required String timeRange,
  });
}
