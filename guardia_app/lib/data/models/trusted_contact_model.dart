import 'package:guardia_app/domain/entities/trusted_contact.dart';

class TrustedContactModel extends TrustedContact {
  const TrustedContactModel({
    required super.id,
    required super.userId,
    required super.contactName,
    required super.contactPhone,
    required super.isActive, required super.createdAt, super.contactEmail,
    super.updatedAt,
  });

  factory TrustedContactModel.fromJson(Map<String, dynamic> json) {
    return TrustedContactModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contactName: json['contact_name'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
