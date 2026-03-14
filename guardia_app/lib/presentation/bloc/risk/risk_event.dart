import 'package:equatable/equatable.dart';

abstract class RiskEvent extends Equatable {
  const RiskEvent();

  @override
  List<Object?> get props => [];
}

class LoadHeatmapRequested extends RiskEvent {}

class LoadAreaRiskSummaryRequested extends RiskEvent {

  const LoadAreaRiskSummaryRequested(this.latitude, this.longitude);
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
