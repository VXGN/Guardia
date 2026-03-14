import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/routing/get_safe_routes.dart';
import 'package:guardia_app/presentation/bloc/routing/routing_event.dart';
import 'package:guardia_app/presentation/bloc/routing/routing_state.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {

  RoutingBloc({
    required this.getSafeRoutesUseCase,
  }) : super(RoutingInitial()) {
    on<SafeRoutesRequested>(_onSafeRoutesRequested);
  }
  final GetSafeRoutes getSafeRoutesUseCase;

  Future<void> _onSafeRoutesRequested(
    SafeRoutesRequested event,
    Emitter<RoutingState> emit,
  ) async {
    emit(RoutingLoading());
    final result = await getSafeRoutesUseCase(
      originLat: event.originLat,
      originLng: event.originLng,
      destinationLat: event.destinationLat,
      destinationLng: event.destinationLng,
    );
    result.fold(
      (failure) => emit(RoutingError(failure.message)),
      (routes) => emit(SafeRoutesLoaded(routes)),
    );
  }
}
