import 'package:guardia_app/domain/entities/journey_location_log.dart';

class JourneyLocationLogModel extends JourneyLocationLog {
  const JourneyLocationLogModel({
    required super.id,
    required super.journeyId,
    required super.latitude,
    required super.longitude,
    required super.recordedAt,
    required super.isAnomalyFlagged,
  });

  factory JourneyLocationLogModel.fromJson(Map<String, dynamic> json) {
    return JourneyLocationLogModel(
      id: json['id'] as String,
      journeyId: json['journey_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      isAnomalyFlagged: json['is_anomaly_flagged'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journey_id': journeyId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.toIso8601String(),
      'is_anomaly_flagged': isAnomalyFlagged,
    };
  }
}
