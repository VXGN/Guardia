import 'package:equatable/equatable.dart';
import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';

class RoutingState extends Equatable {
  final double? originLat;
  final double? originLng;
  final String? destinationLabel;
  final double? destinationLat;
  final double? destinationLng;
  final bool isRequestingRoutes;
  final List<RouteOptionEntity> routes;
  final RouteOptionEntity? selectedRoute;
  final bool isNavigating;
  final String? errorMessage;

  const RoutingState({
    this.originLat,
    this.originLng,
    this.destinationLabel,
    this.destinationLat,
    this.destinationLng,
    this.isRequestingRoutes = false,
    this.routes = const [],
    this.selectedRoute,
    this.isNavigating = false,
    this.errorMessage,
  });

  factory RoutingState.initial() => const RoutingState();

  RoutingState copyWith({
    double? originLat,
    double? originLng,
    String? destinationLabel,
    double? destinationLat,
    double? destinationLng,
    bool? isRequestingRoutes,
    List<RouteOptionEntity>? routes,
    RouteOptionEntity? selectedRoute,
    bool? isNavigating,
    String? errorMessage,
  }) {
    return RoutingState(
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      isRequestingRoutes: isRequestingRoutes ?? this.isRequestingRoutes,
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isNavigating: isNavigating ?? this.isNavigating,
      errorMessage: errorMessage, // Intentionally not coalescing nulls for clear error
    );
  }

  RoutingState clearError() {
    return RoutingState(
      originLat: originLat,
      originLng: originLng,
      destinationLabel: destinationLabel,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      isRequestingRoutes: isRequestingRoutes,
      routes: routes,
      selectedRoute: selectedRoute,
      isNavigating: isNavigating,
      errorMessage: null,
    );
  }

  RoutingState clearRouteData() {
    return RoutingState(
      originLat: originLat,
      originLng: originLng,
      destinationLabel: null,
      destinationLat: null,
      destinationLng: null,
      isRequestingRoutes: false,
      routes: const [],
      selectedRoute: null,
      isNavigating: isNavigating,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        originLat,
        originLng,
        destinationLabel,
        destinationLat,
        destinationLng,
        isRequestingRoutes,
        routes,
        selectedRoute,
        isNavigating,
        errorMessage,
      ];
}
