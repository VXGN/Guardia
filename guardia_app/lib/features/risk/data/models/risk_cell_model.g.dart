// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_cell_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiskCellModel _$RiskCellModelFromJson(Map<String, dynamic> json) =>
    RiskCellModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      riskScore: (json['riskScore'] as num).toDouble(),
      dominantCategory: json['dominantCategory'] as String?,
    );

Map<String, dynamic> _$RiskCellModelToJson(RiskCellModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'riskScore': instance.riskScore,
      'dominantCategory': instance.dominantCategory,
    };
