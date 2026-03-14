import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportCreatedSuccess extends ReportState {
  const ReportCreatedSuccess(this.report);
  final IncidentReport report;

  @override
  List<Object?> get props => [report];
}

class MyReportsLoaded extends ReportState {
  const MyReportsLoaded(this.reports);
  final List<IncidentReport> reports;

  @override
  List<Object?> get props => [reports];
}

class ReportDetailLoaded extends ReportState {
  const ReportDetailLoaded(this.report);
  final IncidentReport report;

  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  const ReportError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
