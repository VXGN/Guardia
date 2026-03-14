import 'package:guardia_app/data/models/journey_contact_model.dart';
import 'package:guardia_app/data/models/journey_location_log_model.dart';
import 'package:guardia_app/domain/entities/journey.dart';

class JourneyModel extends Journey {
  const JourneyModel({
    required super.id,
    required super.userId,
    required super.status,
    required super.startedAt,
    required super.safeArrivalConfirmed, required super.createdAt, required super.contacts, required super.locationLogs, super.endedAt,
    super.originLat,
    super.originLng,
    super.destinationLat,
    super.destinationLng,
    super.updatedAt,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      safeArrivalConfirmed: json['safe_arrival_confirmed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => JourneyContactModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      locationLogs: (json['location_logs'] as List<dynamic>?)
              ?.map((e) => JourneyLocationLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'safe_arrival_confirmed': safeArrivalConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'contacts': contacts.map((e) => (e as JourneyContactModel).toJson()).toList(),
      'location_logs': locationLogs.map((e) => (e as JourneyLocationLogModel).toJson()).toList(),
    };
  }
}
