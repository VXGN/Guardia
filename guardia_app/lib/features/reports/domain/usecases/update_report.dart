import 'dart:io';
import 'package:guardia_app/features/reports/domain/entities/report_entity.dart';
import 'package:guardia_app/features/reports/domain/repositories/report_repository.dart';

class UpdateReport {
  final ReportRepository repository;

  UpdateReport(this.repository);

  Future<void> call(ReportEntity report, List<File> mediaFiles) async {
    return await repository.updateReport(report, mediaFiles);
  }
}
