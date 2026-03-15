import 'package:equatable/equatable.dart';
import 'package:guardia_app/features/panic/domain/entities/panic_session_entity.dart';

enum PanicStatus { 
  idle, 
  countingDown, 
  starting, 
  active, 
  updatingLocation, 
  cancelling, 
  failure 
}

class PanicState extends Equatable {
  static const Object _sessionSentinel = Object();

  final PanicStatus status;
  final PanicSessionEntity? session;
  final String? errorMessage;
  final DateTime? lastLocationUpdateAt;

  const PanicState({
    this.status = PanicStatus.idle,
    this.session,
    this.errorMessage,
    this.lastLocationUpdateAt,
  });

  PanicState copyWith({
    PanicStatus? status,
    Object? session = _sessionSentinel,
    String? errorMessage,
    DateTime? lastLocationUpdateAt,
  }) {
    return PanicState(
      status: status ?? this.status,
      session: identical(session, _sessionSentinel)
          ? this.session
          : session as PanicSessionEntity?,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLocationUpdateAt: lastLocationUpdateAt ?? this.lastLocationUpdateAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        errorMessage,
        lastLocationUpdateAt,
      ];
}
