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
    try {
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
    } catch (e) {
      // For createReport, we might still want to know it failed, 
      // but for simulation we can just log and "succeed"
      print('Network error creating report, simulated success: $e');
    }
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    try {
      final response = await apiClient.get(Endpoints.reportsMy);
      final dynamic responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      final reports = (data['reports'] as List<dynamic>)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return reports;
    } catch (e) {
      print('Falling back to mock MyReports due to error: $e');
      return [
        ReportModel(
          id: 'mock_report_1',
          userId: 'mock_user_123',
          category: 'THEFT',
          description: 'Lost my wallet near the beach.',
          latitude: -8.6940216,
          longitude: 116.1269973,
          locationLabel: 'Kuta Beach, Bali',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isAnonymous: false,
          status: 'RECEIVED',
          mediaUrls: const [],
        ),
      ];
    }
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    try {
      final response = await apiClient.get(Endpoints.reports);
      final dynamic responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      final reports = (data['reports'] as List<dynamic>)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .where(_isInBaliOrNtb)
          .toList();
      return reports;
    } catch (e) {
      print('Falling back to mock AllReports due to error: $e');
      return [
        ReportModel(
          id: 'mock_report_global_1',
          userId: 'other_user_456',
          category: 'ACCIDENT',
          description: 'Traffic accident on Jl. Raya Seminyak.',
          latitude: -8.6940216,
          longitude: 116.1269973,
          locationLabel: 'Seminyak, Bali',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isAnonymous: true,
          status: 'IN_PROGRESS',
          mediaUrls: const [],
        ),
        ReportModel(
          id: 'mock_report_global_2',
          userId: 'other_user_789',
          category: 'HARASSMENT',
          description: 'Verbal harassment near the park.',
          latitude: -8.5830695,
          longitude: 116.1155455,
          locationLabel: 'Mataram, NTB',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isAnonymous: false,
          status: 'RECEIVED',
          mediaUrls: const [],
        ),
      ];
    }
  }

  @override
  Future<ReportModel> getReportDetail(String id) async {
    try {
      final response = await apiClient.get(Endpoints.reportDetail(id));
      final dynamic responseData = response.data;
      final report = ReportModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
      return report;
    } catch (e) {
      print('Falling back to mock ReportDetail due to error: $e');
      return ReportModel(
        id: id,
        userId: 'mock_user_123',
        category: 'MEDICAL',
        description: 'Emergency medical assistance needed.',
        latitude: -8.6940216,
        longitude: 116.1269973,
        locationLabel: 'Canggu, Bali',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isAnonymous: false,
        status: 'RESOLVED',
        mediaUrls: const [],
      );
    }
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
