import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/journey/cancel_journey.dart';
import 'package:guardia_app/domain/usecases/journey/finish_journey.dart';
import 'package:guardia_app/domain/usecases/journey/get_active_journey.dart';
import 'package:guardia_app/domain/usecases/journey/start_journey.dart';
import 'package:guardia_app/domain/usecases/journey/update_journey_location.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_event.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {

  JourneyBloc({
    required this.startJourneyUseCase,
    required this.getActiveJourneyUseCase,
    required this.updateJourneyLocationUseCase,
    required this.finishJourneyUseCase,
    required this.cancelJourneyUseCase,
  }) : super(JourneyInitial()) {
    on<JourneyStartRequested>(_onJourneyStartRequested);
    on<JourneyLoadActiveRequested>(_onJourneyLoadActiveRequested);
    on<JourneyUpdateLocationRequested>(_onJourneyUpdateLocationRequested);
    on<JourneyFinishRequested>(_onJourneyFinishRequested);
    on<JourneyCancelRequested>(_onJourneyCancelRequested);
  }
  final StartJourney startJourneyUseCase;
  final GetActiveJourney getActiveJourneyUseCase;
  final UpdateJourneyLocation updateJourneyLocationUseCase;
  final FinishJourney finishJourneyUseCase;
  final CancelJourney cancelJourneyUseCase;

  Future<void> _onJourneyStartRequested(
    JourneyStartRequested event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    final result = await startJourneyUseCase(
      originLat: event.originLat,
      originLng: event.originLng,
      destinationLat: event.destinationLat,
      destinationLng: event.destinationLng,
      trustedContactIds: event.trustedContactIds,
    );
    result.fold(
      (failure) => emit(JourneyError(failure.message)),
      (journey) => emit(JourneyActive(journey)),
    );
  }

  Future<void> _onJourneyLoadActiveRequested(
    JourneyLoadActiveRequested event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    final result = await getActiveJourneyUseCase();
    result.fold(
      (failure) => emit(JourneyInitial()), // No active journey is not necessarily an error state
      (journey) => emit(JourneyActive(journey)),
    );
  }

  Future<void> _onJourneyUpdateLocationRequested(
    JourneyUpdateLocationRequested event,
    Emitter<JourneyState> emit,
  ) async {
    // We don't necessarily want to emit JourneyLoading here to avoid UI flickering during tracking
    await updateJourneyLocationUseCase(
      journeyId: event.journeyId,
      latitude: event.latitude,
      longitude: event.longitude,
    );
    // On location update, we typically stay in JourneyActive state but might refresh the journey object if the backend returns it
    // For now, if we need to update the state with the full journey object, we'd need a GetJourneyDetail usecase call
  }

  Future<void> _onJourneyFinishRequested(
    JourneyFinishRequested event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    final result = await finishJourneyUseCase(event.id);
    result.fold(
      (failure) => emit(JourneyError(failure.message)),
      (journey) => emit(JourneyCompleted(journey)),
    );
  }

  Future<void> _onJourneyCancelRequested(
    JourneyCancelRequested event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    final result = await cancelJourneyUseCase(event.id);
    result.fold(
      (failure) => emit(JourneyError(failure.message)),
      (journey) => emit(JourneyCancelled(journey)),
    );
  }
}
