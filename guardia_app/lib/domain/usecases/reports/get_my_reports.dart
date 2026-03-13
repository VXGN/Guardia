import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class GetMyReports {
  final ReportRepository repository;

  GetMyReports(this.repository);

  Future<Either<Failure, List<IncidentReport>>> call() async {
    return await repository.getMyReports();
  }
}
