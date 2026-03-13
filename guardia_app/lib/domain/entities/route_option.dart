import 'package:equatable/equatable.dart';

class RouteOption extends Equatable {
  final String id;
  final String polyline;
  final int distanceMeters;
  final int durationSeconds;
  final double safetyScore;
  final String label; // fastest, safest, balanced

  const RouteOption({
    required this.id,
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.safetyScore,
    required this.label,
  });

  @override
  List<Object?> get props => [
        id,
        polyline,
        distanceMeters,
        durationSeconds,
        safetyScore,
        label,
      ];
}
