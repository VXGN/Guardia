import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'journey_session_model.g.dart';

@JsonSerializable()
class JourneySessionModel extends JourneySessionEntity {
  const JourneySessionModel({
    required super.id,
    required super.userId,
    required super.contactIds,
    required super.startLatitude,
    required super.startLongitude,
    super.currentLatitude,
    super.currentLongitude,
    required super.startedAt,
    super.endedAt,
    super.isActive,
  });

  factory JourneySessionModel.fromJson(Map<String, dynamic> json) =>
      _$JourneySessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$JourneySessionModelToJson(this);

  factory JourneySessionModel.fromEntity(JourneySessionEntity entity) {
    return JourneySessionModel(
      id: entity.id,
      userId: entity.userId,
      contactIds: entity.contactIds,
      startLatitude: entity.startLatitude,
      startLongitude: entity.startLongitude,
      currentLatitude: entity.currentLatitude,
      currentLongitude: entity.currentLongitude,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      isActive: entity.isActive,
    );
  }
}
