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
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? relationship;

  const AddTrustedContactRequested({
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.relationship,
  });

  @override
  List<Object?> get props => [contactName, contactPhone, contactEmail, relationship];
}

class UpdateTrustedContactRequested extends TrustedContactEvent {
  final String id;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String? relationship;
  final bool? isActive;

  const UpdateTrustedContactRequested({
    required this.id,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.relationship,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, contactName, contactPhone, contactEmail, relationship, isActive];
}

class DeleteTrustedContactRequested extends TrustedContactEvent {
  const DeleteTrustedContactRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
