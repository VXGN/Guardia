import 'package:equatable/equatable.dart';

class RouteStepEntity extends Equatable {
  final String instruction;
  final int distanceMeters;
  final int durationSeconds;
  final String type; // turn, roundabout, etc.
  final String modifier; // left, right, straight, etc.

  const RouteStepEntity({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.type,
    required this.modifier,
  });

  @override
  List<Object?> get props => [
        instruction,
        distanceMeters,
        durationSeconds,
        type,
        modifier,
      ];
}
