import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/features/risk/domain/usecases/get_risk_heatmap.dart';
import 'package:guardia_app/features/risk/presentation/bloc/risk/risk_event.dart';
import 'package:guardia_app/features/risk/presentation/bloc/risk/risk_state.dart';

class RiskBloc extends Bloc<RiskEvent, RiskState> {
  final GetRiskHeatmap getRiskHeatmap;

  RiskBloc({required this.getRiskHeatmap}) : super(RiskState.initial()) {
    on<RiskFiltersChanged>(_onRiskFiltersChanged);
    on<RiskRequested>(_onRiskRequested);
  }

  Future<void> _onRiskFiltersChanged(RiskFiltersChanged event, Emitter<RiskState> emit) async {
    emit(state.copyWith(
      categoryFilter: event.categoryFilter,
      timeRange: event.timeRange,
      errorMessage: null, // Clear errors when fetching new data
    ));
    // Automatically fetch when filters change
    add(const RiskRequested());
  }

  Future<void> _onRiskRequested(RiskRequested event, Emitter<RiskState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final cells = await getRiskHeatmap(
        categoryFilter: state.categoryFilter,
        timeRange: state.timeRange,
      );
      emit(state.copyWith(
        isLoading: false,
        cells: cells,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      // In a real app we might map specific failures here
    }
  }
}
