import 'dart:io';

import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
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
    await apiClient.post(
      Endpoints.reports,
      data: {
        'incident_type': report.category,
        'description': report.description ?? 'No additional description provided.',
        'incident_at': report.timestamp.toIso8601String(),
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
}
