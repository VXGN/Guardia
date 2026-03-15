import 'package:guardia_app/features/routing/domain/entities/route_step_entity.dart';

class RouteStepModel extends RouteStepEntity {
  const RouteStepModel({
    required super.instruction,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.type,
    required super.modifier,
  });

  factory RouteStepModel.fromJson(Map<String, dynamic> json) {
    // OSRM 'maneuver' object parsing
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final instruction = maneuver['instruction'] as String? ?? 'Proceed';
    final type = maneuver['type'] as String? ?? 'step';
    final modifier = maneuver['modifier'] as String? ?? 'straight';
    
    return RouteStepModel(
      instruction: instruction,
      distanceMeters: (json['distance'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
      type: type,
      modifier: modifier,
    );
  }

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'distance': distanceMeters,
    'duration': durationSeconds,
    'maneuver': {
      'instruction': instruction,
      'type': type,
      'modifier': modifier,
    },
  };
}
