import 'package:equatable/equatable.dart';

class RiskScore extends Equatable {
  final String id;
  final String segmentId;
  final String timeSlot; // morning, afternoon, evening, night
  final double riskScore;
  final int incidentCount;
  final String? dominantIncidentType;
  final DateTime calculatedAt;
  final DateTime? validUntil;

  const RiskScore({
    required this.id,
    required this.segmentId,
    required this.timeSlot,
    required this.riskScore,
    required this.incidentCount,
    this.dominantIncidentType,
    required this.calculatedAt,
    this.validUntil,
  });

  @override
  List<Object?> get props => [
        id,
        segmentId,
        timeSlot,
        riskScore,
        incidentCount,
        dominantIncidentType,
        calculatedAt,
        validUntil,
      ];
}
