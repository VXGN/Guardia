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
  const HeatmapLoaded(this.clusters);
  final List<HeatmapCluster> clusters;

  @override
  List<Object?> get props => [clusters];
}

class AreaRiskSummaryLoaded extends RiskState {
  const AreaRiskSummaryLoaded(this.summary);
  final Map<String, dynamic> summary;

  @override
  List<Object?> get props => [summary];
}

class RiskError extends RiskState {
  const RiskError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
