import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/features/routing/domain/usecases/get_safe_routes.dart';
import 'package:guardia_app/features/routing/domain/usecases/start_navigation.dart';
import 'package:guardia_app/features/routing/domain/usecases/stop_navigation.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_event.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_state.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  final GetSafeRoutes _getSafeRoutes;
  final StartNavigation _startNavigation;
  final StopNavigation _stopNavigation;

  RoutingBloc({
    required GetSafeRoutes getSafeRoutes,
    required StartNavigation startNavigation,
    required StopNavigation stopNavigation,
  })  : _getSafeRoutes = getSafeRoutes,
        _startNavigation = startNavigation,
        _stopNavigation = stopNavigation,
        super(RoutingState.initial()) {
    on<RoutingOriginChanged>(_onOriginChanged);
    on<RoutingDestinationChanged>(_onDestinationChanged);
    on<RoutingRequested>(_onRoutingRequested);
    on<RoutingOptionSelected>(_onOptionSelected);
    on<NavigationStarted>(_onNavigationStarted);
    on<NavigationStopped>(_onNavigationStopped);
  }

  void _onOriginChanged(RoutingOriginChanged event, Emitter<RoutingState> emit) {
    emit(state.copyWith(
      originLat: event.lat,
      originLng: event.lng,
      errorMessage: null,
    ));
  }

  void _onDestinationChanged(RoutingDestinationChanged event, Emitter<RoutingState> emit) {
    emit(state.copyWith(
      destinationLabel: event.query,
      destinationLat: event.lat,
      destinationLng: event.lng,
      errorMessage: null,
    ));
  }

  Future<void> _onRoutingRequested(RoutingRequested event, Emitter<RoutingState> emit) async {
    // Validate inputs
    if (state.originLat == null || state.originLng == null) {
      emit(state.copyWith(errorMessage: 'Current location is required.'));
      return;
    }
    if (state.destinationLat == null || state.destinationLng == null) {
      emit(state.copyWith(errorMessage: 'Valid destination coordinates are required.'));
      return;
    }

    emit(state.copyWith(isRequestingRoutes: true, errorMessage: null));

    try {
      final routes = await _getSafeRoutes(
        originLat: state.originLat!,
        originLng: state.originLng!,
        destLat: state.destinationLat!,
        destLng: state.destinationLng!,
      );

      emit(state.copyWith(
        isRequestingRoutes: false,
        routes: routes,
        selectedRoute: routes.isNotEmpty ? routes.first : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRequestingRoutes: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onOptionSelected(RoutingOptionSelected event, Emitter<RoutingState> emit) {
    try {
      final selected = state.routes.firstWhere((r) => r.id == event.routeId);
      emit(state.copyWith(selectedRoute: selected, errorMessage: null));
    } catch (_) {
      // Option not found
    }
  }

  Future<void> _onNavigationStarted(NavigationStarted event, Emitter<RoutingState> emit) async {
    if (state.selectedRoute != null) {
      emit(state.copyWith(isNavigating: true, errorMessage: null));
      await _startNavigation(state.selectedRoute!);
    } else {
      emit(state.copyWith(errorMessage: 'No route selected for navigation.'));
    }
  }

  Future<void> _onNavigationStopped(NavigationStopped event, Emitter<RoutingState> emit) async {
    emit(state.clearRouteData().copyWith(isNavigating: false));
    await _stopNavigation();
  }
}
