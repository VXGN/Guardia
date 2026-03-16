import 'package:equatable/equatable.dart';
import 'dart:async';

abstract class PanicEvent extends Equatable {
  const PanicEvent();

  @override
  List<Object?> get props => [];
}

class PanicButtonPressed extends PanicEvent {}

class PanicCountdownFinished extends PanicEvent {}

class PanicLocationUpdated extends PanicEvent {
  final double latitude;
  final double longitude;

  const PanicLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class PanicCancelRequested extends PanicEvent {
  final String? emergencyCode;

  const PanicCancelRequested({this.emergencyCode});

  @override
  List<Object?> get props => [emergencyCode];
}

class PanicCountdownPinSubmitted extends PanicEvent {
  final String emergencyCode;
  final Completer<bool> result;

  const PanicCountdownPinSubmitted({
    required this.emergencyCode,
    required this.result,
  });

  @override
  List<Object?> get props => [emergencyCode, result];
}

class PanicResetToIdle extends PanicEvent {}

class PanicLoadEmergencyPin extends PanicEvent {}
