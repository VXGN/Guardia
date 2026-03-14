import 'package:equatable/equatable.dart';

abstract class PanicState extends Equatable {
  const PanicState();

  @override
  List<Object?> get props => [];
}

class PanicInitial extends PanicState {}

class PanicLoading extends PanicState {}

class PanicActive extends PanicState {}

class PanicCancelled extends PanicState {}

class PanicError extends PanicState {
  const PanicError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
