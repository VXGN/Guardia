// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  category: json['category'] as String,
  description: json['description'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  locationLabel: json['locationLabel'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isAnonymous: json['isAnonymous'] as bool,
  status: json['status'] as String,
  mediaUrls: (json['mediaUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'category': instance.category,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationLabel': instance.locationLabel,
      'timestamp': instance.timestamp.toIso8601String(),
      'isAnonymous': instance.isAnonymous,
      'status': instance.status,
      'mediaUrls': instance.mediaUrls,
    };
