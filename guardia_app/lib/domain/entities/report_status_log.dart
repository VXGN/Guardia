import 'package:equatable/equatable.dart';

class ReportStatusLog extends Equatable {
  final String id;
  final String reportId;
  final String? changedBy;
  final String oldStatus;
  final String newStatus;
  final String? notes;
  final DateTime changedAt;

  const ReportStatusLog({
    required this.id,
    required this.reportId,
    this.changedBy,
    required this.oldStatus,
    required this.newStatus,
    this.notes,
    required this.changedAt,
  });

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
