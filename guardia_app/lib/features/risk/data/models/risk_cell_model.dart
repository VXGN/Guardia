import 'package:guardia_app/features/risk/domain/entities/risk_cell_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'risk_cell_model.g.dart';

@JsonSerializable()
class RiskCellModel extends RiskCellEntity {
  const RiskCellModel({
    required super.latitude,
    required super.longitude,
    required super.riskScore,
    super.dominantCategory,
  });

  factory RiskCellModel.fromJson(Map<String, dynamic> json) => _$RiskCellModelFromJson(json);

  Map<String, dynamic> toJson() => _$RiskCellModelToJson(this);

  factory RiskCellModel.fromEntity(RiskCellEntity entity) {
    return RiskCellModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      riskScore: entity.riskScore,
      dominantCategory: entity.dominantCategory,
    );
  }
}
