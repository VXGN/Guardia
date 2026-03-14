import 'package:guardia_app/domain/entities/risk_score.dart';

class RiskScoreModel extends RiskScore {
  const RiskScoreModel({
    required super.id,
    required super.segmentId,
    required super.timeSlot,
    required super.riskScore,
    required super.incidentCount,
    required super.calculatedAt, super.dominantIncidentType,
    super.validUntil,
  });

  factory RiskScoreModel.fromJson(Map<String, dynamic> json) {
    return RiskScoreModel(
      id: json['id'] as String,
      segmentId: json['segment_id'] as String,
      timeSlot: json['time_slot'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      incidentCount: json['incident_count'] as int,
      dominantIncidentType: json['dominant_incident_type'] as String?,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'segment_id': segmentId,
      'time_slot': timeSlot,
      'risk_score': riskScore,
      'incident_count': incidentCount,
      'dominant_incident_type': dominantIncidentType,
      'calculated_at': calculatedAt.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
    };
  }
}
