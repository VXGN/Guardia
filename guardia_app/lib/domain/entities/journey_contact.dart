import 'package:equatable/equatable.dart';

class JourneyContact extends Equatable {
  final String id;
  final String journeyId;
  final String trustedContactId;
  final DateTime? notifiedAt;
  final DateTime? alertSentAt;

  const JourneyContact({
    required this.id,
    required this.journeyId,
    required this.trustedContactId,
    this.notifiedAt,
    this.alertSentAt,
  });

  @override
  List<Object?> get props => [
        id,
        journeyId,
        trustedContactId,
        notifiedAt,
        alertSentAt,
      ];
}
