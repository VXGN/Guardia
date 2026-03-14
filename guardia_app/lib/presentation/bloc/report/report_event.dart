import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class CreateReportRequested extends ReportEvent {

  const CreateReportRequested({
    required this.incidentType,
    required this.incidentAt, required this.latitude, required this.longitude, required this.isAnonymous, this.description,
    this.locationLabel,
  });
  final String incidentType;
  final String? description;
  final DateTime incidentAt;
  final double latitude;
  final double longitude;
  final bool isAnonymous;
  final String? locationLabel;

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
  const LoadReportDetailRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
