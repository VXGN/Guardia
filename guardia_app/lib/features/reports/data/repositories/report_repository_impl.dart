import 'dart:io';
import 'package:guardia_app/features/reports/domain/entities/report_entity.dart';
import 'package:guardia_app/features/reports/domain/repositories/report_repository.dart';
import 'package:guardia_app/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:guardia_app/features/reports/data/models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createReport(ReportEntity report, List<File> mediaFiles) async {
    try {
      final model = ReportModel.fromEntity(report);
      await _remoteDataSource.createReport(model, mediaFiles);
    } catch (e) {
      // TODO: Handle exceptions and throw custom failures
      rethrow;
    }
  }

  @override
  Future<List<ReportEntity>> getMyReports() async {
    try {
      final models = await _remoteDataSource.getMyReports();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ReportEntity>> getAllReports() async {
    try {
      final models = await _remoteDataSource.getAllReports();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReportEntity> getReportDetail(String id) async {
    try {
      final model = await _remoteDataSource.getReportDetail(id);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
