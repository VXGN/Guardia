import 'package:equatable/equatable.dart';
import 'package:guardia_app/features/routing/domain/entities/route_step_entity.dart';
import 'package:latlong2/latlong.dart';

class RouteOptionEntity extends Equatable {
  final String id;
  final String label; // "fastest", "safest", "balanced"
  final String displayName; // "Tercepat", "Paling Aman", dll.
  final int durationSeconds;
  final int distanceMeters;
  final double safetyScore; // 0-100 (higher = safer)
  final String polyline;
  final List<LatLng> points;
  final List<RouteStepEntity> steps;

  const RouteOptionEntity({
    required this.id,
    required this.label,
    required this.displayName,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.safetyScore,
    required this.polyline,
    required this.points,
    this.steps = const [],
  });

  @override
  List<Object?> get props => [
        id,
        label,
        displayName,
        durationSeconds,
        distanceMeters,
        safetyScore,
        polyline,
        points,
      ];
}
