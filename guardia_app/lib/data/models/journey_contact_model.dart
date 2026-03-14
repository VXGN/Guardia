import 'package:guardia_app/domain/entities/journey_contact.dart';

class JourneyContactModel extends JourneyContact {
  const JourneyContactModel({
    required super.id,
    required super.journeyId,
    required super.trustedContactId,
    super.notifiedAt,
    super.alertSentAt,
  });

  factory JourneyContactModel.fromJson(Map<String, dynamic> json) {
    return JourneyContactModel(
      id: json['id'] as String,
      journeyId: json['journey_id'] as String,
      trustedContactId: json['trusted_contact_id'] as String,
      notifiedAt: json['notified_at'] != null ? DateTime.parse(json['notified_at'] as String) : null,
      alertSentAt: json['alert_sent_at'] != null ? DateTime.parse(json['alert_sent_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journey_id': journeyId,
      'trusted_contact_id': trustedContactId,
      'notified_at': notifiedAt?.toIso8601String(),
      'alert_sent_at': alertSentAt?.toIso8601String(),
    };
  }
}
