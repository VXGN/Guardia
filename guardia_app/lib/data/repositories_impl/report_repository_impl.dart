import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/incident_report_model.dart';
import 'package:guardia_app/data/models/report_media_model.dart';
import 'package:guardia_app/data/models/report_status_log_model.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';
import 'package:guardia_app/domain/entities/report_media.dart';
import 'package:guardia_app/domain/entities/report_status_log.dart';
import 'package:guardia_app/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient apiClient;

  ReportRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, IncidentReport>> createReport({
    required String incidentType,
    String? description,
    required DateTime incidentAt,
    required double latitude,
    required double longitude,
    required bool isAnonymous,
    String? locationLabel,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.reports,
        data: {
          'incident_type': incidentType,
          'description': description,
          'incident_at': incidentAt.toIso8601String(),
          'latitude': latitude,
          'longitude': longitude,
          'is_anonymous': isAnonymous,
          'location_label': locationLabel,
        },
      );

      final report = IncidentReportModel.fromJson(response.data['data']);
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create report'));
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

      final media = ReportMediaModel.fromJson(response.data['data']);
      return Right(media);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to upload media'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncidentReport>>> getMyReports() async {
    try {
      final response = await apiClient.get(Endpoints.reports);
      final reports = (response.data['data'] as List)
          .map((e) => IncidentReportModel.fromJson(e))
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
      final report = IncidentReportModel.fromJson(response.data['data']);
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
      final response = await apiClient.get(Endpoints.reportStatusLogs(reportId));
      final logs = (response.data['data'] as List)
          .map((e) => ReportStatusLogModel.fromJson(e))
          .toList();
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load status logs'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
