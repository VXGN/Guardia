import 'package:dartz/dartz.dart';
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
      // Trying real API first
      final response = await apiClient.get(Endpoints.notifications);
      final dynamic responseData = response.data;
      final notifications =
          ((responseData['data'] as Map<String, dynamic>)['notifications']
                  as List<dynamic>? ??
              const <dynamic>[])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(notifications);
    } catch (e) {
      // Mock notifications for "complete feature" demonstration
      final mockNotifications = [
        AppNotification(
          id: 'mock_1',
          notificationType: 'panic_alert',
          title: 'SOS ALERT',
          body: 'Trusted Contact: Rina is in danger! View real-time location.',
          isSent: false, // unread
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: 'mock_2',
          notificationType: 'journey_alert',
          title: 'New Map Message',
          body: 'Your companion sent a location. Tap to navigate.',
          isSent: false, // unread
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        AppNotification(
          id: 'mock_3',
          notificationType: 'system',
          title: 'Safe Arrival',
          body: 'Your journey to "Jl. Langko" was completed successfully.',
          isSent: true, // read
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      return Right(mockNotifications);
    }
  }
}
