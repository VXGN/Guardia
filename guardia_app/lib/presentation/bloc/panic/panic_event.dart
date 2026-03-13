import 'package:equatable/equatable.dart';

abstract class PanicEvent extends Equatable {
  const PanicEvent();

  @override
  List<Object?> get props => [];
}

class PanicTriggerRequested extends PanicEvent {
  final double latitude;
  final double longitude;

  const PanicTriggerRequested({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class PanicCancelRequested extends PanicEvent {}
