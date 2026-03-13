import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/risk/get_area_risk_summary.dart';
import 'package:guardia_app/domain/usecases/risk/get_heatmap_clusters.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_event.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_state.dart';

class RiskBloc extends Bloc<RiskEvent, RiskState> {
  final GetHeatmapClusters getHeatmapUseCase;
  final GetAreaRiskSummary getRiskSummaryUseCase;

  RiskBloc({
    required this.getHeatmapUseCase,
    required this.getRiskSummaryUseCase,
  }) : super(RiskInitial()) {
    on<LoadHeatmapRequested>(_onLoadHeatmapRequested);
    on<LoadAreaRiskSummaryRequested>(_onLoadAreaRiskSummaryRequested);
  }

  Future<void> _onLoadHeatmapRequested(
    LoadHeatmapRequested event,
    Emitter<RiskState> emit,
  ) async {
    emit(RiskLoading());
    final result = await getHeatmapUseCase();
    result.fold(
      (failure) => emit(RiskError(failure.message)),
      (clusters) => emit(HeatmapLoaded(clusters)),
    );
  }

  Future<void> _onLoadAreaRiskSummaryRequested(
    LoadAreaRiskSummaryRequested event,
    Emitter<RiskState> emit,
  ) async {
    // Usually we don't want to emit loading for background updates like this
    final result = await getRiskSummaryUseCase(
      latitude: event.latitude,
      longitude: event.longitude,
    );
    result.fold(
      (failure) => emit(RiskError(failure.message)),
      (summary) => emit(AreaRiskSummaryLoaded(summary)),
    );
  }
}
