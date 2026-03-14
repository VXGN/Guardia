import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetMyReports {
  final ReportRepository repository;

  GetMyReports(this.repository);

  Future<List<ReportEntity>> call() {
    return repository.getMyReports();
  }
}
