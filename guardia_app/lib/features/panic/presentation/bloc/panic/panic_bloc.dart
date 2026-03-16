import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/utils/location_utils.dart';
import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';
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
  final PanicRepository panicRepository;

  StreamSubscription? _locationSubscription;

  /// Cached emergency PIN hash (scrypt "salt:hash") for local verification.
  String? _cachedPinHash;

  PanicBloc({
    required this.startPanicUseCase,
    required this.updatePanicLocationUseCase,
    required this.cancelPanicUseCase,
    required this.panicAlertService,
    required this.panicRepository,
  }) : super(const PanicState()) {
    on<PanicButtonPressed>(_onPanicButtonPressed);
    on<PanicCountdownFinished>(_onPanicCountdownFinished);
    on<PanicLocationUpdated>(_onPanicLocationUpdated);
    on<PanicCancelRequested>(_onPanicCancelRequested);
    on<PanicCountdownPinSubmitted>(_onCountdownPinSubmitted);
    on<PanicResetToIdle>(_onPanicResetToIdle);
    on<PanicLoadEmergencyPin>(_onLoadEmergencyPin);
  }

  Future<void> _onLoadEmergencyPin(
    PanicLoadEmergencyPin event,
    Emitter<PanicState> emit,
  ) async {
    try {
      _cachedPinHash = await panicRepository.fetchEmergencyPinHash();
      print('Emergency PIN hash cached: ${_cachedPinHash != null}');
    } catch (e) {
      print('Failed to fetch emergency PIN hash: $e');
    }
  }

  Future<void> _onPanicButtonPressed(
    PanicButtonPressed event,
    Emitter<PanicState> emit,
  ) async {
    // Guard: only allow triggering from idle state
    if (state.status != PanicStatus.idle && state.status != PanicStatus.failure) {
      print('SOS Button Pressed ignored — current status: ${state.status}');
      return;
    }

    print('SOS Button Pressed - Checking permissions...');

    // Use geolocator's native permission check (handles service state internally)
    final isPermissionGranted = await LocationUtils.checkAndRequestPermission();
    if (!isPermissionGranted) {
      print('SOS Failure: Location permission not granted.');
      emit(state.copyWith(
        status: PanicStatus.failure,
        errorMessage:
            'Izin lokasi diperlukan untuk SOS. Pastikan GPS aktif dan izin lokasi diberikan.',
      ));
      return;
    }

    // Pre-fetch PIN hash if not cached
    if (_cachedPinHash == null) {
      try {
        _cachedPinHash = await panicRepository.fetchEmergencyPinHash();
      } catch (e) {
        print('Failed to pre-fetch PIN hash: $e');
      }
    }

    // If permission granted, move to countdown status
    print('SOS Status: Countdown started.');
    emit(state.copyWith(status: PanicStatus.countingDown));
  }

  Future<void> _onPanicCountdownFinished(
    PanicCountdownFinished event,
    Emitter<PanicState> emit,
  ) async {
    // Guard: only process if still in countdown state
    if (state.status != PanicStatus.countingDown) {
      print('PanicCountdownFinished ignored — current status: ${state.status}');
      return;
    }

    print('SOS Status: Countdown finished. Starting session...');
    emit(state.copyWith(status: PanicStatus.starting));

    try {
      // Get initial location
      final position = await LocationUtils.getCurrentPosition();
      print('Initial SOS Location: Lat=${position.latitude}, Lng=${position.longitude}');

      // Guard: if session was cancelled while we fetched location, abort
      if (state.status != PanicStatus.starting) {
        print('SOS Start aborted — state changed to ${state.status} during location fetch.');
        return;
      }

      // Call use case to start panic session
      final session = await startPanicUseCase(
        lat: position.latitude,
        lng: position.longitude,
      );

      // Guard: abort if cancelled while awaiting the start call
      if (state.status != PanicStatus.starting) {
        print('SOS Start aborted — state changed to ${state.status} during start call.');
        return;
      }

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
      // Guard: suppress failure if session was already cancelled
      if (state.status == PanicStatus.idle) return;
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

      // Guard: do NOT re-emit active if session was cancelled during the await
      if (state.session == null || state.status == PanicStatus.idle) {
        print('Location update completed but session already cancelled. Ignoring.');
        return;
      }

      emit(state.copyWith(
        status: PanicStatus.active,
        lastLocationUpdateAt: DateTime.now(),
      ));
    } catch (e) {
      if (_isNoActivePanicError(e)) {
        print('Backend reports panic is no longer active. Stopping SOS locally.');
        _stopLocationStreaming();
        unawaited(panicAlertService.stop());
        emit(state.copyWith(status: PanicStatus.idle, session: null));
        return;
      }

      // Log transient network errors but keep session active.
      print('Failed to send real-time update to backend: $e');
    }
  }

  Future<void> _onPanicCancelRequested(
    PanicCancelRequested event,
    Emitter<PanicState> emit,
  ) async {
    final emergencyCode = event.emergencyCode?.trim();
    final sessionId = state.session?.id;

    // Always reset state to idle immediately — do not wait for backend.
    _stopLocationStreaming();
    unawaited(panicAlertService.stop());
    emit(const PanicState());

    // Fire backend cancel in background (non-blocking).
    unawaited(() async {
      try {
        await cancelPanicUseCase(
          sessionId: sessionId,
          emergencyCode: emergencyCode,
        );
        print('SOS Session Cancelled on backend successfully.');
      } catch (e) {
        print('SOS Cancel Error (non-blocking): $e');
      }
    }());
  }

  Future<void> _onCountdownPinSubmitted(
    PanicCountdownPinSubmitted event,
    Emitter<PanicState> emit,
  ) async {
    // Guard: only process if still counting down
    if (state.status != PanicStatus.countingDown) {
      if (!event.result.isCompleted) {
        event.result.complete(false);
      }
      return;
    }

    print('SOS PIN verification starting...');
    bool isValid = false;
    try {
      await cancelPanicUseCase(emergencyCode: event.emergencyCode);
      isValid = true;
      print('SOS PIN verified via backend.');
    } catch (e) {
      print('SOS Countdown PIN backend verification failed: $e');
      isValid = false;
    }

    if (isValid) {
      print('SOS PIN verified — resetting to idle.');

      // Immediately reset to idle — this is the authoritative state change.
      emit(const PanicState());

      if (!event.result.isCompleted) {
        event.result.complete(true);
      }

      // Notify backend in background if we verified locally.
      if (_cachedPinHash != null) {
        unawaited(() async {
          try {
            await cancelPanicUseCase(emergencyCode: event.emergencyCode);
            print('Background countdown cancel synced to backend successfully.');
          } catch (e) {
            print('Background countdown cancel failed (non-fatal): $e');
          }
        }());
      }
    } else {
      print('SOS PIN verification failed.');
      if (!event.result.isCompleted) {
        event.result.complete(false);
      }
    }
  }

  void _onPanicResetToIdle(
    PanicResetToIdle event,
    Emitter<PanicState> emit,
  ) {
    print('SOS Status: Resetting to idle.');
    _stopLocationStreaming();
    unawaited(panicAlertService.stop());
    emit(const PanicState());
  }

  bool _isNoActivePanicError(Object error) {
    final message = _extractApiErrorMessage(error);
    return message.contains('no active panic') ||
        message.contains('no active panic alert') ||
        message.contains('cancelled');
  }

  String _extractApiErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        return (responseData['message'] ?? '').toString().toLowerCase();
      }
    }

    return error.toString().toLowerCase();
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
    unawaited(panicAlertService.stop());
    return super.close();
  }
}
