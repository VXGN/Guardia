import 'package:equatable/equatable.dart';

class ReportStatusLog extends Equatable {

  const ReportStatusLog({
    required this.id,
    required this.reportId,
    required this.oldStatus, required this.newStatus, required this.changedAt, this.changedBy,
    this.notes,
  });
  final String id;
  final String reportId;
  final String? changedBy;
  final String oldStatus;
  final String newStatus;
  final String? notes;
  final DateTime changedAt;

  @override
  List<Object?> get props => [
        id,
        reportId,
        changedBy,
        oldStatus,
        newStatus,
        notes,
        changedAt,
      ];
}
