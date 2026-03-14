import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';
import 'package:guardia_app/domain/repositories/notification_repository.dart';

class GetNotifications {

  GetNotifications(this.repository);
  final NotificationRepository repository;

  Future<Either<Failure, List<AppNotification>>> call() async {
    return repository.getNotifications();
  }
}
