import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/risk_repository.dart';

class GetAreaRiskSummary {

  GetAreaRiskSummary(this.repository);
  final RiskRepository repository;

  Future<Either<Failure, Map<String, dynamic>>> call({
    required double latitude,
    required double longitude,
  }) async {
    return repository.getAreaRiskSummary(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
