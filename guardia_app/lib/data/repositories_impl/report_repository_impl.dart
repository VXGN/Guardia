import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/mappers/incident_type_mapper.dart';
import 'package:guardia_app/data/models/incident_report_model.dart';
import 'package:guardia_app/data/models/report_status_log_model.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/entities/report_media.dart';
import 'package:guardia_app/domain/entities/report_status_log.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {

  ReportRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, IncidentReport>> createReport({
    required String incidentType,
    required DateTime incidentAt, required double latitude, required double longitude, required bool isAnonymous, String? description,
    String? locationLabel,
  }) async {
    try {
      final mappedIncidentType = IncidentTypeMapper.toBackend(incidentType);

      final response = await apiClient.post(
        Endpoints.reports,
        data: {
          'incident_type': mappedIncidentType,
          'description': (description == null || description.trim().isEmpty)
              ? 'No additional description provided.'
              : description,
          'incident_at': incidentAt.toIso8601String(),
          'latitude': latitude,
          'longitude': longitude,
          'is_anonymous': isAnonymous,
          'location_label': locationLabel,
        },
      );

      final dynamic responseData = response.data;
      final report = IncidentReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create report'));
    } on FormatException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportMedia>> uploadReportMedia({
    required String reportId,
    required String filePath,
    required String mediaType,
  }) async {
    return Left(
      ServerFailure('Report media upload is not available in current backend API'),
    );

    /*
    try {
      final file = File(filePath);
      final formData = FormData.fromMap({
        'media_type': mediaType,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await apiClient.post(
        Endpoints.reportMedia(reportId),
        data: formData,
      );

      final dynamic responseData = response.data;
      final media = ReportMediaModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(media);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to upload media'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, List<IncidentReport>>> getMyReports() async {
    try {
      final response = await apiClient.get(Endpoints.reportsMy);
      final dynamic responseData = response.data;
      final reports = ((responseData['data'] as Map<String, dynamic>)['reports']
              as List<dynamic>)
          .map((e) => IncidentReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(reports);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load reports'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, IncidentReport>> getReportDetail(String id) async {
    try {
      final response = await apiClient.get(Endpoints.reportDetail(id));
      final dynamic responseData = response.data;
      final report = IncidentReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load report detail'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportStatusLog>>> getReportStatusLogs(String reportId) async {
    try {
      final response = await apiClient.get(Endpoints.reportDetail(reportId));
      final dynamic responseData = response.data;
      final reportData = responseData['data'] as Map<String, dynamic>;
      final logs = (reportData['report_status_logs'] as List<dynamic>? ?? const [])
          .map((e) => ReportStatusLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load status logs'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
