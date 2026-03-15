import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/utils/location_utils.dart';
import 'package:guardia_app/features/panic/domain/usecases/start_panic.dart';
import 'package:guardia_app/features/panic/domain/usecases/update_panic_location.dart';
import 'package:guardia_app/features/panic/domain/usecases/cancel_panic.dart';
import 'package:guardia_app/core/services/panic_alert_service.dart';
import 'panic_event.dart';
import 'panic_state.dart';

class PanicBloc extends Bloc<PanicEvent, PanicState> {
  final StartPanic startPanicUseCase;
  final UpdatePanicLocation updatePanicLocationUseCase;
  final CancelPanicAction cancelPanicUseCase;
  final PanicAlertService panicAlertService;

  StreamSubscription? _locationSubscription;

  PanicBloc({
    required this.startPanicUseCase,
    required this.updatePanicLocationUseCase,
    required this.cancelPanicUseCase,
    required this.panicAlertService,
  }) : super(const PanicState()) {
    on<PanicButtonPressed>(_onPanicButtonPressed);
    on<PanicCountdownFinished>(_onPanicCountdownFinished);
    on<PanicLocationUpdated>(_onPanicLocationUpdated);
    on<PanicCancelRequested>(_onPanicCancelRequested);
    on<PanicResetToIdle>(_onPanicResetToIdle);
  }

  Future<void> _onPanicButtonPressed(
    PanicButtonPressed event,
    Emitter<PanicState> emit,
  ) async {
    print('SOS Button Pressed - Checking permissions...');
    // Check and request location permission
    final isPermissionGranted = await LocationUtils.checkAndRequestPermission();
    if (!isPermissionGranted) {
      print('SOS Failure: Location permission denied.');
      emit(state.copyWith(
        status: PanicStatus.failure,
        errorMessage: 'Izin lokasi ditolak. Tidak dapat mengirim SOS.',
      ));
      return;
    }

    // If permission granted, move to countdown status
    print('SOS Status: Countdown started.');
    emit(state.copyWith(status: PanicStatus.countingDown));
  }

  Future<void> _onPanicCountdownFinished(
    PanicCountdownFinished event,
    Emitter<PanicState> emit,
  ) async {
    print('SOS Status: Countdown finished. Starting session...');
    emit(state.copyWith(status: PanicStatus.starting));

    try {
      // Get initial location
      final position = await LocationUtils.getCurrentPosition();
      print('Initial SOS Location: Lat=${position.latitude}, Lng=${position.longitude}');
      
      // Call use case to start panic session
      final session = await startPanicUseCase(
        lat: position.latitude,
        lng: position.longitude,
      );

      print('SOS Session Started: ${session.id}');

      emit(state.copyWith(
        status: PanicStatus.active,
        session: session,
        lastLocationUpdateAt: DateTime.now(),
      ));

      // Start periodic location updates (real-time stream)
      _startLocationStreaming();

      // Start sound and vibration
      panicAlertService.start();
    } catch (e) {
      print('SOS Start Error: $e');
      emit(state.copyWith(
        status: PanicStatus.failure,
        errorMessage: 'Gagal memulai sesi darurat: $e',
      ));
    }
  }

  Future<void> _onPanicLocationUpdated(
    PanicLocationUpdated event,
    Emitter<PanicState> emit,
  ) async {
    if (state.session == null) return;

    print('Real-time SOS Update: Lat=${event.latitude}, Lng=${event.longitude}');

    try {
      await updatePanicLocationUseCase(
        sessionId: state.session!.id,
        lat: event.latitude,
        lng: event.longitude,
      );

      emit(state.copyWith(
        status: PanicStatus.active,
        lastLocationUpdateAt: DateTime.now(),
      ));
    } catch (e) {
      // Log error but keep session active
      print('Failed to send real-time update to backend: $e');
    }
  }

  Future<void> _onPanicCancelRequested(
    PanicCancelRequested event,
    Emitter<PanicState> emit,
  ) async {
    if (state.session == null) {
       emit(state.copyWith(status: PanicStatus.idle, session: null));
       return;
    }

    final sessionId = state.session!.id;
    print('SOS Status: Cancelling session $sessionId...');

    // Close SOS immediately on UI while backend cancellation is processed.
    _stopLocationStreaming();
    panicAlertService.stop();
    emit(state.copyWith(status: PanicStatus.idle, session: null));

    try {
      await cancelPanicUseCase(sessionId: sessionId);
      print('SOS Session Cancelled successfully.');
    } catch (e) {
      // Keep the UI closed; backend/network failure should not re-open SOS session.
      print('SOS Cancel Error (non-blocking): $e');
    }
  }

  void _onPanicResetToIdle(
    PanicResetToIdle event,
    Emitter<PanicState> emit,
  ) {
    print('SOS Status: Resetting to idle.');
    _stopLocationStreaming();
    panicAlertService.stop();
    emit(const PanicState());
  }

  void _startLocationStreaming() {
    _stopLocationStreaming(); // Ensure no duplicate subs
    print('Starting Real-time Location Stream for SOS...');
    _locationSubscription = LocationUtils.getPositionStream().listen(
      (position) {
        add(PanicLocationUpdated(
          latitude: position.latitude,
          longitude: position.longitude,
        ));
      },
      onError: (e) {
        print('Error in SOS Location Stream: $e');
      },
    );
  }

  void _stopLocationStreaming() {
    print('Stopping SOS Location Stream.');
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  Future<void> close() {
    _stopLocationStreaming();
    return super.close();
  }
}
