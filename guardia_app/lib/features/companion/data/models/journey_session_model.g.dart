// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneySessionModel _$JourneySessionModelFromJson(Map<String, dynamic> json) =>
    JourneySessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contactIds: (json['contactIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startLatitude: (json['startLatitude'] as num).toDouble(),
      startLongitude: (json['startLongitude'] as num).toDouble(),
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$JourneySessionModelToJson(
  JourneySessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'contactIds': instance.contactIds,
  'startLatitude': instance.startLatitude,
  'startLongitude': instance.startLongitude,
  'currentLatitude': instance.currentLatitude,
  'currentLongitude': instance.currentLongitude,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
  'isActive': instance.isActive,
};
