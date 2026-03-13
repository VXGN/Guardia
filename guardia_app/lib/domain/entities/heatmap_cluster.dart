import 'package:equatable/equatable.dart';

class HeatmapCluster extends Equatable {
  final String id;
  final double centerLatBlurred;
  final double centerLngBlurred;
  final int radiusMeters;
  final String intensity; // low, medium, high, critical
  final int incidentCount;
  final String? dominantType;
  final String? timeSlot;
  final DateTime validFrom;
  final DateTime validUntil;
  final DateTime createdAt;

  const HeatmapCluster({
    required this.id,
    required this.centerLatBlurred,
    required this.centerLngBlurred,
    required this.radiusMeters,
    required this.intensity,
    required this.incidentCount,
    this.dominantType,
    this.timeSlot,
    required this.validFrom,
    required this.validUntil,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        centerLatBlurred,
        centerLngBlurred,
        radiusMeters,
        intensity,
        incidentCount,
        dominantType,
        timeSlot,
        validFrom,
        validUntil,
        createdAt,
      ];
}
