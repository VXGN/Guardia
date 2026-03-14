import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/route_option.dart';

abstract class RoutingState extends Equatable {
  const RoutingState();

  @override
  List<Object?> get props => [];
}

class RoutingInitial extends RoutingState {}

class RoutingLoading extends RoutingState {}

class SafeRoutesLoaded extends RoutingState {
  const SafeRoutesLoaded(this.routes);
  final List<RouteOption> routes;

  @override
  List<Object?> get props => [routes];
}

class RoutingError extends RoutingState {
  const RoutingError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
