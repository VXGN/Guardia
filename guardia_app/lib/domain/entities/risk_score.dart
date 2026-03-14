import 'package:equatable/equatable.dart';

class RiskScore extends Equatable {

  const RiskScore({
    required this.id,
    required this.segmentId,
    required this.timeSlot,
    required this.riskScore,
    required this.incidentCount,
    required this.calculatedAt, this.dominantIncidentType,
    this.validUntil,
  });
  final String id;
  final String segmentId;
  final String timeSlot; // morning, afternoon, evening, night
  final double riskScore;
  final int incidentCount;
  final String? dominantIncidentType;
  final DateTime calculatedAt;
  final DateTime? validUntil;

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
