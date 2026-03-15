import 'package:equatable/equatable.dart';

class PanicSessionEntity extends Equatable {
  final String id;
  final String userId;
  final double lastLatitude;
  final double lastLongitude;
  final DateTime startedAt;
  final bool isActive;

  const PanicSessionEntity({
    required this.id,
    required this.userId,
    required this.lastLatitude,
    required this.lastLongitude,
    required this.startedAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        lastLatitude,
        lastLongitude,
        startedAt,
        isActive,
      ];
}
