import 'dart:io';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<void> createReport(ReportModel report, List<File> mediaFiles);
  Future<List<ReportModel>> getMyReports();
  Future<ReportModel> getReportDetail(String id);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient;

  ReportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> createReport(ReportModel report, List<File> mediaFiles) async {
    // Note: If you need to upload files, you'll likely need to use FormData
    // For now, assuming standard JSON payload if files aren't implemented in BE yet.
    // If BE expects multipart/form-data, use Dio's FormData.
    
    // Example with FormData (commented out until BE confirms):
    /*
    final formData = FormData.fromMap({
      ...report.toJson(),
      'files': [
        for (var file in mediaFiles)
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
      ],
    });
    */

    // Reverted to mock data until backend is ready
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    // Reverted to mock data until backend is ready
    await Future.delayed(const Duration(seconds: 1));
    return [
      ReportModel(
        id: 'mock-1',
        userId: 'user-1',
        category: 'Suspicious Activity',
        description: 'Saw someone loitering near the parking lot.',
        latitude: -8.5830695,
        longitude: 116.1155455,
        locationLabel: 'Plaza Mataram',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isAnonymous: false,
        status: 'RECEIVED',
        mediaUrls: const [],
      ),
      ReportModel(
        id: 'mock-2',
        userId: 'user-1',
        category: 'Broken Streetligh',
        description: 'Streetlight is out on Main St.',
        latitude: -8.5900,
        longitude: 116.1000,
        locationLabel: 'Main St.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isAnonymous: true,
        status: 'RESOLVED',
        mediaUrls: const [],
      ),
    ];
  }

  @override
  Future<ReportModel> getReportDetail(String id) async {
    // Reverted to mock data until backend is ready
    await Future.delayed(const Duration(milliseconds: 500));
    return ReportModel(
        id: id,
        userId: 'user-1',
        category: 'Suspicious Activity',
        description: 'Mock detail description.',
        latitude: -8.5830695,
        longitude: 116.1155455,
        locationLabel: 'Plaza Mataram',
        timestamp: DateTime.now(),
        isAnonymous: false,
        status: 'RECEIVED',
        mediaUrls: const [],
      );
  }
}
