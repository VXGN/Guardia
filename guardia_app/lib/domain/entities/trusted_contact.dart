import 'package:equatable/equatable.dart';

class TrustedContact extends Equatable {

  const TrustedContact({
    required this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    required this.isActive, required this.createdAt, this.contactEmail,
    this.updatedAt,
  });
  final String id;
  final String userId;
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        contactName,
        contactPhone,
        contactEmail,
        isActive,
        createdAt,
        updatedAt,
      ];
}
