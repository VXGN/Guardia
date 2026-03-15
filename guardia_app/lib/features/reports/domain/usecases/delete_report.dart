import 'package:guardia_app/features/reports/domain/repositories/report_repository.dart';

class DeleteReport {
  final ReportRepository repository;

  DeleteReport(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteReport(id);
  }
}
