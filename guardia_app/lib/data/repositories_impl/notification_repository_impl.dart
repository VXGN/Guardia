import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/notification_model.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';
import 'package:guardia_app/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {

  NotificationRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final response = await apiClient.get(Endpoints.notifications);
      final dynamic responseData = response.data;
      final notifications = (responseData['data'] as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load notifications'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
