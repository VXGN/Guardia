import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';

abstract class RiskState extends Equatable {
  const RiskState();

  @override
  List<Object?> get props => [];
}

class RiskInitial extends RiskState {}

class RiskLoading extends RiskState {}

class HeatmapLoaded extends RiskState {
  final List<HeatmapCluster> clusters;
  const HeatmapLoaded(this.clusters);

  @override
  List<Object?> get props => [clusters];
}

class AreaRiskSummaryLoaded extends RiskState {
  final Map<String, dynamic> summary;
  const AreaRiskSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class RiskError extends RiskState {
  final String message;
  const RiskError(this.message);

  @override
  List<Object?> get props => [message];
}
