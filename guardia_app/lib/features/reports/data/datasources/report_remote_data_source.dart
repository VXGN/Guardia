import 'dart:io';

import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<void> createReport(ReportModel report, List<File> mediaFiles);
  Future<List<ReportModel>> getMyReports();
  Future<List<ReportModel>> getAllReports();
  Future<ReportModel> getReportDetail(String id);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl();

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
  Future<List<ReportModel>> getAllReports() async {
    // Mocking global feed data
    await Future.delayed(const Duration(seconds: 1));
    return [
      ReportModel(
        id: 'global-1',
        userId: 'user-99',
        category: 'Theft',
        description: 'Someone stole my bicycle at the park. Please be careful!',
        latitude: -8.5830695,
        longitude: 116.1155455,
        locationLabel: 'Taman Sangkareang',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isAnonymous: false,
        status: 'RECEIVED',
        mediaUrls: const [],
      ),
      ReportModel(
        id: 'global-2',
        userId: 'user-100',
        category: 'Harassment',
        description: 'Felt unsafe following a suspicious vehicle on Jl. Udayana.',
        latitude: -8.5900,
        longitude: 116.1000,
        locationLabel: 'Jl. Udayana',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isAnonymous: true,
        status: 'RECEIVED',
        mediaUrls: const [],
      ),
      ReportModel(
        id: 'global-3',
        userId: 'user-101',
        category: 'Natural Disaster',
        description: 'Heavy flooding near the traditional market.',
        latitude: -8.5700,
        longitude: 116.1200,
        locationLabel: 'Pasar Kebon Roek',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isAnonymous: false,
        status: 'RECEIVED',
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
