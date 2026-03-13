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
  final IncidentReport report;
  const ReportCreatedSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

class MyReportsLoaded extends ReportState {
  final List<IncidentReport> reports;
  const MyReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportDetailLoaded extends ReportState {
  final IncidentReport report;
  const ReportDetailLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
