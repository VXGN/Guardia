import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetAllReports {
  final ReportRepository repository;

  GetAllReports(this.repository);

  Future<List<ReportEntity>> call() {
    return repository.getAllReports();
  }
}
