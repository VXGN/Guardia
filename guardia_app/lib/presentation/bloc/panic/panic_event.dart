import 'package:equatable/equatable.dart';

abstract class PanicEvent extends Equatable {
  const PanicEvent();

  @override
  List<Object?> get props => [];
}

class PanicTriggerRequested extends PanicEvent {

  const PanicTriggerRequested({
    required this.latitude,
    required this.longitude,
  });
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class PanicCancelRequested extends PanicEvent {}
