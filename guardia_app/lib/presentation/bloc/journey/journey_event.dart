import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/journey.dart';

abstract class JourneyEvent extends Equatable {
  const JourneyEvent();

  @override
  List<Object?> get props => [];
}

class JourneyStartRequested extends JourneyEvent {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final List<String> trustedContactIds;

  const JourneyStartRequested({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.trustedContactIds,
  });

  @override
  List<Object?> get props => [originLat, originLng, destinationLat, destinationLng, trustedContactIds];
}

class JourneyLoadActiveRequested extends JourneyEvent {}

class JourneyUpdateLocationRequested extends JourneyEvent {
  final String journeyId;
  final double latitude;
  final double longitude;

  const JourneyUpdateLocationRequested({
    required this.journeyId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [journeyId, latitude, longitude];
}

class JourneyFinishRequested extends JourneyEvent {
  final String id;
  const JourneyFinishRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class JourneyCancelRequested extends JourneyEvent {
  final String id;
  const JourneyCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}
