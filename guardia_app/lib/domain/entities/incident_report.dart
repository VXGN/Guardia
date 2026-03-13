import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/report_media.dart';
import 'package:guardia_app/domain/entities/report_status_log.dart';

class IncidentReport extends Equatable {
  final String id;
  final String? userId;
  final String incidentType; // verbal_harassment, physical_harassment, stalking, theft, intimidation, other
  final String? description;
  final DateTime incidentAt;
  final double latitude;
  final double longitude;
  final double latitudeBlurred;
  final double longitudeBlurred;
  final String? locationLabel;
  final bool isAnonymous;
  final String status; // received, verified, in_progress, resolved, rejected
  final int? severityScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<ReportMedia> media;
  final List<ReportStatusLog> statusLogs;

  const IncidentReport({
    required this.id,
    this.userId,
    required this.incidentType,
    this.description,
    required this.incidentAt,
    required this.latitude,
    required this.longitude,
    required this.latitudeBlurred,
    required this.longitudeBlurred,
    this.locationLabel,
    required this.isAnonymous,
    required this.status,
    this.severityScore,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.media,
    required this.statusLogs,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        incidentType,
        description,
        incidentAt,
        latitude,
        longitude,
        latitudeBlurred,
        longitudeBlurred,
        locationLabel,
        isAnonymous,
        status,
        severityScore,
        createdAt,
        updatedAt,
        deletedAt,
        media,
        statusLogs,
      ];
}
