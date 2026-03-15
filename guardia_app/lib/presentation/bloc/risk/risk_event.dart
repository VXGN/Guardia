import 'package:equatable/equatable.dart';

abstract class RiskEvent extends Equatable {
  const RiskEvent();

  @override
  List<Object?> get props => [];
}

class LoadHeatmapRequested extends RiskEvent {
  const LoadHeatmapRequested({
    this.latitude,
    this.longitude,
    this.radiusMeters,
  });

  final double? latitude;
  final double? longitude;
  final double? radiusMeters;

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

class LoadAreaRiskSummaryRequested extends RiskEvent {

  const LoadAreaRiskSummaryRequested(
    this.latitude,
    this.longitude, {
    this.radiusMeters,
  });
  final double latitude;
  final double longitude;
  final double? radiusMeters;

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}
