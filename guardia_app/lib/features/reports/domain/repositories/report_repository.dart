import 'dart:io';
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<void> createReport(ReportEntity report, List<File> mediaFiles);
  Future<List<ReportEntity>> getMyReports();
  Future<List<ReportEntity>> getAllReports();
  Future<ReportEntity> getReportDetail(String id);
}
