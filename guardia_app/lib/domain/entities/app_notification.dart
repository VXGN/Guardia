import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String? recipientUserId;
  final String? recipientPhone;
  final String notificationType; // journey_start, journey_safe_arrival, journey_alert, report_status_update, panic_alert, system
  final String title;
  final String body;
  final String? relatedJourneyId;
  final String? relatedReportId;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    this.recipientUserId,
    this.recipientPhone,
    required this.notificationType,
    required this.title,
    required this.body,
    this.relatedJourneyId,
    this.relatedReportId,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        recipientUserId,
        recipientPhone,
        notificationType,
        title,
        body,
        relatedJourneyId,
        relatedReportId,
        isSent,
        sentAt,
        createdAt,
      ];
}
