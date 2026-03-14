import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class GetMyReports {

  GetMyReports(this.repository);
  final ReportRepository repository;

  Future<Either<Failure, List<IncidentReport>>> call() async {
    return repository.getMyReports();
  }
}
