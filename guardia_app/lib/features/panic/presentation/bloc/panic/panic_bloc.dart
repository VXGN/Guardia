import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/utils/location_utils.dart';
import 'package:guardia_app/core/utils/pin_verify.dart';
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

  /// Temporarily stores a locally validated PIN until backend cancel succeeds.
  String? _pendingCountdownCancelPin;
  bool _isPendingCountdownCancelInFlight = false;
  int _pendingCountdownCancelRetryCount = 0;
  static const int _maxPendingCountdownCancelRetries = 3;

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
    _clearPendingCountdownCancelPin();

    // Guard: only allow triggering from idle state
    if (state.status != PanicStatus.idle && state.status != PanicStatus.failure) {
      print('SOS Button Pressed ignored — current status: ${state.status}');
      return;
    }

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

    if (state.session == null && (emergencyCode == null || emergencyCode.isEmpty)) {
      emit(state.copyWith(status: PanicStatus.idle, session: null));
      return;
    }

    if (sessionId != null) {
      print('SOS Status: Cancelling session $sessionId...');

      // Close SOS immediately on UI while backend cancellation is processed.
      _stopLocationStreaming();
      unawaited(panicAlertService.stop());
      emit(state.copyWith(status: PanicStatus.idle, session: null));

      try {
        await cancelPanicUseCase(
          sessionId: sessionId,
          emergencyCode: emergencyCode,
        );
        print('SOS Session Cancelled successfully.');
      } catch (e) {
        // Keep the UI closed; backend/network failure should not re-open SOS session.
        print('SOS Cancel Error (non-blocking): $e');
      }
      return;
    }

    // Countdown stage: validate PIN immediately with backend before trigger fires.
    try {
      await cancelPanicUseCase(emergencyCode: emergencyCode);
      emit(state.copyWith(status: PanicStatus.idle, session: null));
    } catch (e) {
      print('SOS Countdown PIN verification failed: $e');
    }
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

    // Try local verification first (instant, no network latency)
    if (_cachedPinHash != null) {
      final isValid = verifyEmergencyPin(event.emergencyCode, _cachedPinHash!);
      if (isValid) {
        print('SOS PIN verified locally — cancelling countdown.');

        _pendingCountdownCancelPin = event.emergencyCode;
        _pendingCountdownCancelRetryCount = 0;
        emit(state.copyWith(status: PanicStatus.idle, session: null));

        if (!event.result.isCompleted) {
          event.result.complete(true);
        }

        // Notify backend immediately; keep retrying briefly using the cached PIN.
        unawaited(_flushPendingCountdownCancelPin());
        return;
      } else {
        print('SOS PIN local verification failed.');
        if (!event.result.isCompleted) {
          event.result.complete(false);
        }
        return;
      }
    }

    // Fallback: verify via backend when local hash is unavailable.
    try {
      await cancelPanicUseCase(emergencyCode: event.emergencyCode);
      emit(state.copyWith(status: PanicStatus.idle, session: null));
      if (!event.result.isCompleted) {
        event.result.complete(true);
      }
    } catch (e) {
      print('SOS Countdown PIN verification failed: $e');
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
    _clearPendingCountdownCancelPin();
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

  Future<void> _flushPendingCountdownCancelPin() async {
    final pin = _pendingCountdownCancelPin;
    if (pin == null || _isPendingCountdownCancelInFlight) {
      return;
    }

    _isPendingCountdownCancelInFlight = true;
    try {
      await cancelPanicUseCase(emergencyCode: pin);
      print('Background countdown cancel synced to backend successfully.');
      _clearPendingCountdownCancelPin();
      return;
    } catch (e) {
      _pendingCountdownCancelRetryCount += 1;
      print('Background BE cancel attempt $_pendingCountdownCancelRetryCount failed: $e');
    } finally {
      _isPendingCountdownCancelInFlight = false;
    }

    if (_pendingCountdownCancelPin != null &&
        _pendingCountdownCancelRetryCount < _maxPendingCountdownCancelRetries) {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      await _flushPendingCountdownCancelPin();
    }
  }

  void _clearPendingCountdownCancelPin() {
    _pendingCountdownCancelPin = null;
    _pendingCountdownCancelRetryCount = 0;
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
