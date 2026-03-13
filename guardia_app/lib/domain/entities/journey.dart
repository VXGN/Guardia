import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/journey_contact.dart';
import 'package:guardia_app/domain/entities/journey_location_log.dart';

class Journey extends Equatable {
  final String id;
  final String userId;
  final String status; // active, completed, alert_triggered, cancelled
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final bool safeArrivalConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<JourneyContact> contacts;
  final List<JourneyLocationLog> locationLogs;

  const Journey({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    required this.safeArrivalConfirmed,
    required this.createdAt,
    this.updatedAt,
    required this.contacts,
    required this.locationLogs,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        startedAt,
        endedAt,
        originLat,
        originLng,
        destinationLat,
        destinationLng,
        safeArrivalConfirmed,
        createdAt,
        updatedAt,
        contacts,
        locationLogs,
      ];
}
