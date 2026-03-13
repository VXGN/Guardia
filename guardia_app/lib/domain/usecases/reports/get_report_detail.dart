import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class GetReportDetail {
  final ReportRepository repository;

  GetReportDetail(this.repository);

  Future<Either<Failure, IncidentReport>> call(String id) async {
    return await repository.getReportDetail(id);
  }
}
