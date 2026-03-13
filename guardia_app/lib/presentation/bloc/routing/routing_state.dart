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
  final List<RouteOption> routes;
  const SafeRoutesLoaded(this.routes);

  @override
  List<Object?> get props => [routes];
}

class RoutingError extends RoutingState {
  final String message;
  const RoutingError(this.message);

  @override
  List<Object?> get props => [message];
}
