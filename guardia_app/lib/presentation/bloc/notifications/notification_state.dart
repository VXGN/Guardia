import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded(this.notifications);
  final List<AppNotification> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
