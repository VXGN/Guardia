import 'package:equatable/equatable.dart';

class RiskCellEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double riskScore; // 0-100
  final String? dominantCategory;

  const RiskCellEntity({
    required this.latitude,
    required this.longitude,
    required this.riskScore,
    this.dominantCategory,
  });

  @override
  List<Object?> get props => [latitude, longitude, riskScore, dominantCategory];
}
