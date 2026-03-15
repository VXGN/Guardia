import 'package:equatable/equatable.dart';

class TrustedContact extends Equatable {
  final String id;
  final String userId;
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? relationship;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrustedContact({
    required this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.relationship,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        contactName,
        contactPhone,
        contactEmail,
        relationship,
        isActive,
        createdAt,
        updatedAt,
      ];
}
