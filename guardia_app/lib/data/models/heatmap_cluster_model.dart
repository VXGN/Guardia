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
      id: (json['id'] ?? '').toString(),
      centerLatBlurred: _toDouble(json['center_lat_blurred']),
      centerLngBlurred: _toDouble(json['center_lng_blurred']),
      radiusMeters: _toInt(json['radius_meters']),
      intensity: (json['intensity'] ?? 'low').toString(),
      incidentCount: _toInt(json['incident_count']),
      dominantType: json['dominant_type']?.toString(),
      timeSlot: json['time_slot']?.toString(),
      validFrom: _toDateTime(json['valid_from']),
      validUntil: _toDateTime(json['valid_until']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
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
