import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/report_media.dart';
import 'package:guardia_app/domain/entities/report_status_log.dart';

class IncidentReport extends Equatable {

  const IncidentReport({
    required this.id,
    required this.incidentType, required this.incidentAt, required this.latitude, required this.longitude, required this.latitudeBlurred, required this.longitudeBlurred, required this.isAnonymous, required this.status, required this.createdAt, required this.media, required this.statusLogs, this.userId,
    this.description,
    this.locationLabel,
    this.severityScore,
    this.updatedAt,
    this.deletedAt,
  });
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
