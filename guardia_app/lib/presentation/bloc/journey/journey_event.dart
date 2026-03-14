import 'package:equatable/equatable.dart';

abstract class JourneyEvent extends Equatable {
  const JourneyEvent();

  @override
  List<Object?> get props => [];
}

class JourneyStartRequested extends JourneyEvent {

  const JourneyStartRequested({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.trustedContactIds,
  });
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final List<String> trustedContactIds;

  @override
  List<Object?> get props => [originLat, originLng, destinationLat, destinationLng, trustedContactIds];
}

class JourneyLoadActiveRequested extends JourneyEvent {}

class JourneyUpdateLocationRequested extends JourneyEvent {

  const JourneyUpdateLocationRequested({
    required this.journeyId,
    required this.latitude,
    required this.longitude,
  });
  final String journeyId;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [journeyId, latitude, longitude];
}

class JourneyFinishRequested extends JourneyEvent {
  const JourneyFinishRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class JourneyCancelRequested extends JourneyEvent {
  const JourneyCancelRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
