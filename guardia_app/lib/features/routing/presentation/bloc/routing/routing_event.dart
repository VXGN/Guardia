import 'package:equatable/equatable.dart';

abstract class RoutingEvent extends Equatable {
  const RoutingEvent();

  @override
  List<Object?> get props => [];
}

class RoutingOriginChanged extends RoutingEvent {
  final double lat;
  final double lng;

  const RoutingOriginChanged(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}

class RoutingDestinationChanged extends RoutingEvent {
  final String query;
  final double? lat;
  final double? lng;

  const RoutingDestinationChanged({
    required this.query,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [query, lat, lng];
}

class RoutingRequested extends RoutingEvent {
  const RoutingRequested();
}

class RoutingOptionSelected extends RoutingEvent {
  final String routeId;

  const RoutingOptionSelected(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class NavigationStarted extends RoutingEvent {
  const NavigationStarted();
}

class NavigationStopped extends RoutingEvent {
  const NavigationStopped();
}
