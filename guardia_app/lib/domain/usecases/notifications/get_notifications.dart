import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';
import 'package:guardia_app/domain/repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<AppNotification>>> call() async {
    return await repository.getNotifications();
  }
}
