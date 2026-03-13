import 'package:guardia_app/domain/entities/route_option.dart';

class RouteOptionModel extends RouteOption {
  const RouteOptionModel({
    required super.id,
    required super.polyline,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.safetyScore,
    required super.label,
  });

  factory RouteOptionModel.fromJson(Map<String, dynamic> json) {
    return RouteOptionModel(
      id: json['id'] as String,
      polyline: json['polyline'] as String,
      distanceMeters: json['distance_meters'] as int,
      durationSeconds: json['duration_seconds'] as int,
      safetyScore: (json['safety_score'] as num).toDouble(),
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'polyline': polyline,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'safety_score': safetyScore,
      'label': label,
    };
  }
}
