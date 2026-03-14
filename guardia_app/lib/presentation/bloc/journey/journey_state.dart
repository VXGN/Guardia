import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/journey.dart';

abstract class JourneyState extends Equatable {
  const JourneyState();

  @override
  List<Object?> get props => [];
}

class JourneyInitial extends JourneyState {}

class JourneyLoading extends JourneyState {}

class JourneyActive extends JourneyState {
  const JourneyActive(this.journey);
  final Journey journey;

  @override
  List<Object?> get props => [journey];
}

class JourneyCompleted extends JourneyState {
  const JourneyCompleted(this.journey);
  final Journey journey;

  @override
  List<Object?> get props => [journey];
}

class JourneyCancelled extends JourneyState {
  const JourneyCancelled(this.journey);
  final Journey journey;

  @override
  List<Object?> get props => [journey];
}

class JourneyError extends JourneyState {
  const JourneyError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
