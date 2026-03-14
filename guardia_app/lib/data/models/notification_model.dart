import 'package:guardia_app/domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.notificationType, required super.title, required super.body, required super.isSent, required super.createdAt, super.recipientUserId,
    super.recipientPhone,
    super.relatedJourneyId,
    super.relatedReportId,
    super.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientUserId: json['recipient_user_id'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      relatedJourneyId: json['related_journey_id'] as String?,
      relatedReportId: json['related_report_id'] as String?,
      isSent: json['is_sent'] as bool,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_user_id': recipientUserId,
      'recipient_phone': recipientPhone,
      'notification_type': notificationType,
      'title': title,
      'body': body,
      'related_journey_id': relatedJourneyId,
      'related_report_id': relatedReportId,
      'is_sent': isSent,
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
