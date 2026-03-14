import 'package:guardia_app/domain/entities/road_segment.dart';

class RoadSegmentModel extends RoadSegment {
  const RoadSegmentModel({
    required super.id,
    required super.startLat, required super.startLng, required super.endLat, required super.endLng, required super.hasStreetLight, required super.isMainRoad, required super.nearSecurityPost, required super.createdAt, super.segmentName,
    super.lengthMeters,
    super.osmWayId,
    super.updatedAt,
  });

  factory RoadSegmentModel.fromJson(Map<String, dynamic> json) {
    return RoadSegmentModel(
      id: json['id'] as String,
      segmentName: json['segment_name'] as String?,
      startLat: (json['start_lat'] as num).toDouble(),
      startLng: (json['start_lng'] as num).toDouble(),
      endLat: (json['end_lat'] as num).toDouble(),
      endLng: (json['end_lng'] as num).toDouble(),
      lengthMeters: json['length_meters'] as int?,
      hasStreetLight: json['has_street_light'] as bool,
      isMainRoad: json['is_main_road'] as bool,
      nearSecurityPost: json['near_security_post'] as bool,
      osmWayId: json['osm_way_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'segment_name': segmentName,
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'length_meters': lengthMeters,
      'has_street_light': hasStreetLight,
      'is_main_road': isMainRoad,
      'near_security_post': nearSecurityPost,
      'osm_way_id': osmWayId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
