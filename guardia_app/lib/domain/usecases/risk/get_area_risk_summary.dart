import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';

class GetAreaRiskSummary {
  final RiskRepository repository;

  GetAreaRiskSummary(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required double latitude,
    required double longitude,
  }) async {
    return await repository.getAreaRiskSummary(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
