// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrustedContactModel _$TrustedContactModelFromJson(Map<String, dynamic> json) =>
    TrustedContactModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String?,
      relationship: json['relationship'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrustedContactModelToJson(
  TrustedContactModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'contactEmail': instance.contactEmail,
  'relationship': instance.relationship,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
