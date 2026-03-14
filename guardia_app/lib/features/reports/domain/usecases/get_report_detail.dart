import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetReportDetail {
  final ReportRepository repository;

  GetReportDetail(this.repository);

  Future<ReportEntity> call(String id) {
    return repository.getReportDetail(id);
  }
}
