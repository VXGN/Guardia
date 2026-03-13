import 'package:guardia_app/domain/entities/report_status_log.dart';

class ReportStatusLogModel extends ReportStatusLog {
  const ReportStatusLogModel({
    required super.id,
    required super.reportId,
    super.changedBy,
    required super.oldStatus,
    required super.newStatus,
    super.notes,
    required super.changedAt,
  });

  factory ReportStatusLogModel.fromJson(Map<String, dynamic> json) {
    return ReportStatusLogModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      changedBy: json['changed_by'] as String?,
      oldStatus: json['old_status'] as String,
      newStatus: json['new_status'] as String,
      notes: json['notes'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'changed_by': changedBy,
      'old_status': oldStatus,
      'new_status': newStatus,
      'notes': notes,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
