import 'package:equatable/equatable.dart';

abstract class TrustedContactEvent extends Equatable {
  const TrustedContactEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrustedContactsRequested extends TrustedContactEvent {
  const LoadTrustedContactsRequested();
}

class AddTrustedContactRequested extends TrustedContactEvent {

  const AddTrustedContactRequested({
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
  });
  final String contactName;
  final String contactPhone;
  final String? contactEmail;

  @override
  List<Object?> get props => [contactName, contactPhone, contactEmail];
}

class UpdateTrustedContactRequested extends TrustedContactEvent {

  const UpdateTrustedContactRequested({
    required this.id,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.isActive,
  });
  final String id;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final bool? isActive;

  @override
  List<Object?> get props => [id, contactName, contactPhone, contactEmail, isActive];
}

class DeleteTrustedContactRequested extends TrustedContactEvent {
  const DeleteTrustedContactRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
