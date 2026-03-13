import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/entities/report_media.dart';
import 'package:guardia_app/domain/entities/report_status_log.dart';

abstract class ReportRepository {
  Future<Either<Failure, IncidentReport>> createReport({
    required String incidentType,
    String? description,
    required DateTime incidentAt,
    required double latitude,
    required double longitude,
    required bool isAnonymous,
    String? locationLabel,
  });

  Future<Either<Failure, ReportMedia>> uploadReportMedia({
    required String reportId,
    required String filePath,
    required String mediaType,
  });

  Future<Either<Failure, List<IncidentReport>>> getMyReports();

  Future<Either<Failure, IncidentReport>> getReportDetail(String id);

  Future<Either<Failure, List<ReportStatusLog>>> getReportStatusLogs(String reportId);
}
