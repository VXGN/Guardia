import 'package:json_annotation/json_annotation.dart';
import 'package:guardia_app/features/reports/domain/entities/report_entity.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    @JsonKey(name: 'user_id') super.userId,
    required super.category,
    super.description,
    required super.latitude,
    required super.longitude,
    required super.locationLabel,
    required super.timestamp,
    required super.isAnonymous,
    required super.status,
    required super.mediaUrls,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      userId: entity.userId,
      category: entity.category,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      locationLabel: entity.locationLabel,
      timestamp: entity.timestamp,
      isAnonymous: entity.isAnonymous,
      status: entity.status,
      mediaUrls: entity.mediaUrls,
    );
  }

  ReportEntity toEntity() {
    return ReportEntity(
      id: id,
      userId: userId,
      category: category,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
      timestamp: timestamp,
      isAnonymous: isAnonymous,
      status: status,
      mediaUrls: mediaUrls,
    );
  }
}
