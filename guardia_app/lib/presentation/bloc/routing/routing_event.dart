import 'package:equatable/equatable.dart';

abstract class RoutingEvent extends Equatable {
  const RoutingEvent();

  @override
  List<Object?> get props => [];
}

class SafeRoutesRequested extends RoutingEvent {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  const SafeRoutesRequested({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  List<Object?> get props => [originLat, originLng, destinationLat, destinationLng];
}
