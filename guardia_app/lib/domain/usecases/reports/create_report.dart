import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class CreateReport {

  CreateReport(this.repository);
  final ReportRepository repository;

  Future<Either<Failure, IncidentReport>> call({
    required String incidentType,
    required DateTime incidentAt, required double latitude, required double longitude, required bool isAnonymous, String? description,
    String? locationLabel,
  }) async {
    return repository.createReport(
      incidentType: incidentType,
      description: description,
      incidentAt: incidentAt,
      latitude: latitude,
      longitude: longitude,
      isAnonymous: isAnonymous,
      locationLabel: locationLabel,
    );
  }
}
