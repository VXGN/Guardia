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
    final calculatedAtRaw =
        (json['calculated_at'] ?? json['created_at']) as String?;

    return RiskScoreModel(
      id: json['id'] as String,
      segmentId: json['segment_id'] as String,
      timeSlot: json['time_slot'] as String,
      riskScore: _toDouble(json['risk_score']),
      incidentCount: _toInt(json['incident_count']),
      dominantIncidentType: json['dominant_incident_type'] as String?,
      calculatedAt: calculatedAtRaw != null
          ? DateTime.parse(calculatedAtRaw)
          : DateTime.now(),
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

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
