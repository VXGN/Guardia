import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';

abstract class TrustedContactState extends Equatable {
  const TrustedContactState();

  @override
  List<Object?> get props => [];
}

class TrustedContactInitial extends TrustedContactState {}

class TrustedContactLoading extends TrustedContactState {}

class TrustedContactsLoaded extends TrustedContactState {
  const TrustedContactsLoaded(this.contacts);
  final List<TrustedContact> contacts;

  @override
  List<Object?> get props => [contacts];
}

class TrustedContactError extends TrustedContactState {
  const TrustedContactError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
