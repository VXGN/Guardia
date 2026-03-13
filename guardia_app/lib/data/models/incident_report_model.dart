import 'package:guardia_app/data/models/report_media_model.dart';
import 'package:guardia_app/data/models/report_status_log_model.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';

class IncidentReportModel extends IncidentReport {
  const IncidentReportModel({
    required super.id,
    super.userId,
    required super.incidentType,
    super.description,
    required super.incidentAt,
    required super.latitude,
    required super.longitude,
    required super.latitudeBlurred,
    required super.longitudeBlurred,
    super.locationLabel,
    required super.isAnonymous,
    required super.status,
    super.severityScore,
    required super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required super.media,
    required super.statusLogs,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    return IncidentReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      incidentType: json['incident_type'] as String,
      description: json['description'] as String?,
      incidentAt: DateTime.parse(json['incident_at'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      latitudeBlurred: (json['latitude_blurred'] as num).toDouble(),
      longitudeBlurred: (json['longitude_blurred'] as num).toDouble(),
      locationLabel: json['location_label'] as String?,
      isAnonymous: json['is_anonymous'] as bool,
      status: json['status'] as String,
      severityScore: json['severity_score'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => ReportMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusLogs: (json['status_logs'] as List<dynamic>?)
              ?.map((e) => ReportStatusLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'incident_type': incidentType,
      'description': description,
      'incident_at': incidentAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'latitude_blurred': latitudeBlurred,
      'longitude_blurred': longitudeBlurred,
      'location_label': locationLabel,
      'is_anonymous': isAnonymous,
      'status': status,
      'severity_score': severityScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'media': media.map((e) => (e as ReportMediaModel).toJson()).toList(),
      'status_logs': statusLogs.map((e) => (e as ReportStatusLogModel).toJson()).toList(),
    };
  }
}
