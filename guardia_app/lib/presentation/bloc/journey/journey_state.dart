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
  final Journey journey;
  const JourneyActive(this.journey);

  @override
  List<Object?> get props => [journey];
}

class JourneyCompleted extends JourneyState {
  final Journey journey;
  const JourneyCompleted(this.journey);

  @override
  List<Object?> get props => [journey];
}

class JourneyCancelled extends JourneyState {
  final Journey journey;
  const JourneyCancelled(this.journey);

  @override
  List<Object?> get props => [journey];
}

class JourneyError extends JourneyState {
  final String message;
  const JourneyError(this.message);

  @override
  List<Object?> get props => [message];
}
