import 'package:equatable/equatable.dart';

class JourneyLocationLog extends Equatable {

  const JourneyLocationLog({
    required this.id,
    required this.journeyId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.isAnomalyFlagged,
  });
  final String id;
  final String journeyId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final bool isAnomalyFlagged;

  @override
  List<Object?> get props => [
        id,
        journeyId,
        latitude,
        longitude,
        recordedAt,
        isAnomalyFlagged,
      ];
}
