import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {

  const AppNotification({
    required this.id,
    required this.notificationType, required this.title, required this.body, required this.isSent, required this.createdAt, this.recipientUserId,
    this.recipientPhone,
    this.relatedJourneyId,
    this.relatedReportId,
    this.sentAt,
  });
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
