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

  /// Custom fromJson that handles both local format and backend API format
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Handle backend API format (incident_type, incident_at, etc.)
    if (json.containsKey('incident_type') || json.containsKey('incident_at')) {
      final latitude = _parseCoordinate(
        json['latitude_blurred'] ?? json['latitude'] ?? json['latitude_exact'],
      );
      final longitude = _parseCoordinate(
        json['longitude_blurred'] ?? json['longitude'] ?? json['longitude_exact'],
      );

      // Parse timestamp from incident_at or created_at
      final timestampStr = json['incident_at'] ?? json['created_at'];
      final timestamp = timestampStr != null
          ? DateTime.parse(timestampStr as String)
          : DateTime.now();

      // Extract media URLs from report_media if available
      final mediaList = json['report_media'] as List<dynamic>? ?? [];
      final mediaUrls = mediaList
          .map((m) => (m as Map<String, dynamic>)['storage_url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();

      return ReportModel(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        category: json['incident_type'] as String? ?? 'other',
        description: json['description'] as String?,
        latitude: latitude,
        longitude: longitude,
        locationLabel: json['location_label'] as String? ?? '',
        timestamp: timestamp,
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        status: (json['status'] as String? ?? 'received').toUpperCase(),
        mediaUrls: mediaUrls,
      );
    }

    // Fallback to generated parser for local format
    return _$ReportModelFromJson(json);
  }

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

  static double _parseCoordinate(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}
