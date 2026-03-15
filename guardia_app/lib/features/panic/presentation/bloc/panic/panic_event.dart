import 'package:equatable/equatable.dart';

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

class PanicCancelRequested extends PanicEvent {}

class PanicResetToIdle extends PanicEvent {}
