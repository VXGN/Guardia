import 'package:equatable/equatable.dart';
import 'package:guardia_app/features/risk/domain/entities/risk_cell_entity.dart';

class RiskState extends Equatable {
  final List<RiskCellEntity> cells;
  final String categoryFilter;
  final String timeRange;
  final bool isLoading;
  final String? errorMessage;

  const RiskState({
    required this.cells,
    required this.categoryFilter,
    required this.timeRange,
    required this.isLoading,
    this.errorMessage,
  });

  factory RiskState.initial() {
    return const RiskState(
      cells: [],
      categoryFilter: 'all',
      timeRange: '7d', // default values from requirements
      isLoading: false,
      errorMessage: null,
    );
  }

  RiskState copyWith({
    List<RiskCellEntity>? cells,
    String? categoryFilter,
    String? timeRange,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RiskState(
      cells: cells ?? this.cells,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      timeRange: timeRange ?? this.timeRange,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // We don't use ?? here so we can clear errors by passing null
    );
  }

  // Helper method so we can explicitly clear the error message without copyWith complexity
  RiskState clearError() {
    return RiskState(
      cells: cells,
      categoryFilter: categoryFilter,
      timeRange: timeRange,
      isLoading: isLoading,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        cells,
        categoryFilter,
        timeRange,
        isLoading,
        errorMessage,
      ];
}
