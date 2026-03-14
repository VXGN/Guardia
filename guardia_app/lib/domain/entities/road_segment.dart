import 'package:equatable/equatable.dart';

class RoadSegment extends Equatable {

  const RoadSegment({
    required this.id,
    required this.startLat, required this.startLng, required this.endLat, required this.endLng, required this.hasStreetLight, required this.isMainRoad, required this.nearSecurityPost, required this.createdAt, this.segmentName,
    this.lengthMeters,
    this.osmWayId,
    this.updatedAt,
  });
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
