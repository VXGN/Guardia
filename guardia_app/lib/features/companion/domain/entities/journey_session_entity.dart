import 'package:equatable/equatable.dart';

class JourneySessionEntity extends Equatable {
  final String id;
  final String userId;
  final List<String> contactIds;
  final double startLatitude;
  final double startLongitude;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isActive;

  const JourneySessionEntity({
    required this.id,
    required this.userId,
    required this.contactIds,
    required this.startLatitude,
    required this.startLongitude,
    this.currentLatitude,
    this.currentLongitude,
    required this.startedAt,
    this.endedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        contactIds,
        startLatitude,
        startLongitude,
        currentLatitude,
        currentLongitude,
        startedAt,
        endedAt,
        isActive,
      ];
}
