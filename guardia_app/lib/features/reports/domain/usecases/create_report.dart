import 'dart:io';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class CreateReport {
  final ReportRepository repository;

  CreateReport(this.repository);

  Future<void> call(ReportEntity report, List<File> mediaFiles) {
    return repository.createReport(report, mediaFiles);
  }
}
