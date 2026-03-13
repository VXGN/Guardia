import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class CreateReportRequested extends ReportEvent {
  final String incidentType;
  final String? description;
  final DateTime incidentAt;
  final double latitude;
  final double longitude;
  final bool isAnonymous;
  final String? locationLabel;

  const CreateReportRequested({
    required this.incidentType,
    this.description,
    required this.incidentAt,
    required this.latitude,
    required this.longitude,
    required this.isAnonymous,
    this.locationLabel,
  });

  @override
  List<Object?> get props => [
        incidentType,
        description,
        incidentAt,
        latitude,
        longitude,
        isAnonymous,
        locationLabel,
      ];
}

class LoadMyReportsRequested extends ReportEvent {}

class LoadReportDetailRequested extends ReportEvent {
  final String id;
  const LoadReportDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}
