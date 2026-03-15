import 'dart:io';

import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/mappers/incident_type_mapper.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<void> createReport(ReportModel report, List<File> mediaFiles);
  Future<List<ReportModel>> getMyReports();
  Future<List<ReportModel>> getAllReports();
  Future<ReportModel> getReportDetail(String id);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<void> createReport(ReportModel report, List<File> mediaFiles) async {
    final normalizedType = IncidentTypeMapper.toBackend(report.category);
    final normalizedDescription = _normalizeDescription(report.description);

    await apiClient.post(
      Endpoints.reports,
      data: {
        'incident_type': normalizedType,
        'description': normalizedDescription,
        'incident_at': report.timestamp.toUtc().toIso8601String(),
        'latitude': report.latitude,
        'longitude': report.longitude,
        'is_anonymous': report.isAnonymous,
        'location_label': report.locationLabel,
      },
    );
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    final response = await apiClient.get(Endpoints.reportsMy);
    final dynamic responseData = response.data;
    final data = responseData['data'] as Map<String, dynamic>;
    final reports = (data['reports'] as List<dynamic>)
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return reports;
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    final response = await apiClient.get(Endpoints.reports);
    final dynamic responseData = response.data;
    final data = responseData['data'] as Map<String, dynamic>;
    final reports = (data['reports'] as List<dynamic>)
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .where(_isInBaliOrNtb)
        .toList();
    return reports;
  }

  @override
  Future<ReportModel> getReportDetail(String id) async {
    final response = await apiClient.get(Endpoints.reportDetail(id));
    final dynamic responseData = response.data;
    final report = ReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
    return report;
  }

  String _normalizeDescription(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.length >= 10) {
      return trimmed;
    }

    return 'Incident reported by user through Guardia app.';
  }

  bool _isInBaliOrNtb(ReportModel report) {
    const minLat = -9.5;
    const maxLat = -7.5;
    const minLng = 114.0;
    const maxLng = 119.7;

    return report.latitude >= minLat &&
        report.latitude <= maxLat &&
        report.longitude >= minLng &&
        report.longitude <= maxLng;
  }
}
