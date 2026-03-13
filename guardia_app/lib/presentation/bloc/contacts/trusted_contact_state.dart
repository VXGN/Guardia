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
  final List<TrustedContact> contacts;
  const TrustedContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class TrustedContactError extends TrustedContactState {
  final String message;
  const TrustedContactError(this.message);

  @override
  List<Object?> get props => [message];
}
