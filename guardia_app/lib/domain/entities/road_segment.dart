import 'package:equatable/equatable.dart';

class RoadSegment extends Equatable {
  final String id;
  final String? segmentName;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final int? lengthMeters;
  final bool hasStreetLight;
  final bool isMainRoad;
  final bool nearSecurityPost;
  final int? osmWayId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RoadSegment({
    required this.id,
    this.segmentName,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    this.lengthMeters,
    required this.hasStreetLight,
    required this.isMainRoad,
    required this.nearSecurityPost,
    this.osmWayId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        segmentName,
        startLat,
        startLng,
        endLat,
        endLng,
        lengthMeters,
        hasStreetLight,
        isMainRoad,
        nearSecurityPost,
        osmWayId,
        createdAt,
        updatedAt,
      ];
}
