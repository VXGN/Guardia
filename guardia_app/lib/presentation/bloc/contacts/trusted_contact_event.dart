import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';

abstract class TrustedContactEvent extends Equatable {
  const TrustedContactEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrustedContactsRequested extends TrustedContactEvent {}

class AddTrustedContactRequested extends TrustedContactEvent {
  final String contactName;
  final String contactPhone;
  final String? contactEmail;

  const AddTrustedContactRequested({
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
  });

  @override
  List<Object?> get props => [contactName, contactPhone, contactEmail];
}

class UpdateTrustedContactRequested extends TrustedContactEvent {
  final String id;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final bool? isActive;

  const UpdateTrustedContactRequested({
    required this.id,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, contactName, contactPhone, contactEmail, isActive];
}

class DeleteTrustedContactRequested extends TrustedContactEvent {
  final String id;
  const DeleteTrustedContactRequested(this.id);

  @override
  List<Object?> get props => [id];
}
