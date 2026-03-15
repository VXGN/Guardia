import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trusted_contact_model.g.dart';

@JsonSerializable()
class TrustedContactModel extends TrustedContactEntity {
  const TrustedContactModel({
    required super.id,
    required super.userId,
    required super.contactName,
    required super.contactPhone,
    super.contactEmail,
    super.relationship,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
  });

  factory TrustedContactModel.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrustedContactModelToJson(this);

  factory TrustedContactModel.fromEntity(TrustedContactEntity entity) {
    return TrustedContactModel(
      id: entity.id,
      userId: entity.userId,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      relationship: entity.relationship,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
