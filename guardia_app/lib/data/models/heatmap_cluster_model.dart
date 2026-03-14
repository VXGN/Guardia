import 'package:guardia_app/domain/entities/heatmap_cluster.dart';

class HeatmapClusterModel extends HeatmapCluster {
  const HeatmapClusterModel({
    required super.id,
    required super.centerLatBlurred,
    required super.centerLngBlurred,
    required super.radiusMeters,
    required super.intensity,
    required super.incidentCount,
    required super.validFrom, required super.validUntil, required super.createdAt, super.dominantType,
    super.timeSlot,
  });

  factory HeatmapClusterModel.fromJson(Map<String, dynamic> json) {
    return HeatmapClusterModel(
      id: json['id'] as String,
      centerLatBlurred: (json['center_lat_blurred'] as num).toDouble(),
      centerLngBlurred: (json['center_lng_blurred'] as num).toDouble(),
      radiusMeters: json['radius_meters'] as int,
      intensity: json['intensity'] as String,
      incidentCount: json['incident_count'] as int,
      dominantType: json['dominant_type'] as String?,
      timeSlot: json['time_slot'] as String?,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_lat_blurred': centerLatBlurred,
      'center_lng_blurred': centerLngBlurred,
      'radius_meters': radiusMeters,
      'intensity': intensity,
      'incident_count': incidentCount,
      'dominant_type': dominantType,
      'time_slot': timeSlot,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
