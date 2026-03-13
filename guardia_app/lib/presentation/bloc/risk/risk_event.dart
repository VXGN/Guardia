import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';

abstract class RiskEvent extends Equatable {
  const RiskEvent();

  @override
  List<Object?> get props => [];
}

class LoadHeatmapRequested extends RiskEvent {}

class LoadAreaRiskSummaryRequested extends RiskEvent {
  final double latitude;
  final double longitude;

  const LoadAreaRiskSummaryRequested(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}
