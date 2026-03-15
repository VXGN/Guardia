import 'package:equatable/equatable.dart';

class TrustedContactEntity extends Equatable {
  final String id;
  final String userId;
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? relationship;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrustedContactEntity({
    required this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.relationship,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  TrustedContactEntity copyWith({
    String? id,
    String? userId,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? relationship,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContactEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      relationship: relationship ?? this.relationship,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
