import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/panic/cancel_panic.dart';
import 'package:guardia_app/domain/usecases/panic/trigger_panic.dart';
import 'package:guardia_app/presentation/bloc/panic/panic_event.dart';
import 'package:guardia_app/presentation/bloc/panic/panic_state.dart';

class PanicBloc extends Bloc<PanicEvent, PanicState> {
  final TriggerPanic triggerPanicUseCase;
  final CancelPanic cancelPanicUseCase;

  PanicBloc({
    required this.triggerPanicUseCase,
    required this.cancelPanicUseCase,
  }) : super(PanicInitial()) {
    on<PanicTriggerRequested>(_onPanicTriggerRequested);
    on<PanicCancelRequested>(_onPanicCancelRequested);
  }

  Future<void> _onPanicTriggerRequested(
    PanicTriggerRequested event,
    Emitter<PanicState> emit,
  ) async {
    emit(PanicLoading());
    final result = await triggerPanicUseCase(
      latitude: event.latitude,
      longitude: event.longitude,
    );
    result.fold(
      (failure) => emit(PanicError(failure.message)),
      (_) => emit(PanicActive()),
    );
  }

  Future<void> _onPanicCancelRequested(
    PanicCancelRequested event,
    Emitter<PanicState> emit,
  ) async {
    emit(PanicLoading());
    final result = await cancelPanicUseCase();
    result.fold(
      (failure) => emit(PanicError(failure.message)),
      (_) => emit(PanicCancelled()),
    );
  }
}
