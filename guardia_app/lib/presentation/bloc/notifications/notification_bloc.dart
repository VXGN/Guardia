import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/notifications/get_notifications.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_event.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  NotificationBloc({
    required this.getNotificationsUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotificationsRequested>(_onLoadNotificationsRequested);
  }
  final GetNotifications getNotificationsUseCase;

  Future<void> _onLoadNotificationsRequested(
    LoadNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }
}
