import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_bloc.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_event.dart';
import 'package:guardia_app/presentation/bloc/notifications/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotificationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<NotificationBloc>().add(LoadNotificationsRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications =
              state is NotificationsLoaded ? state.notifications : const <AppNotification>[];

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationTile(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    IconData icon;
    Color iconColor;

    switch (notification.notificationType) {
      case 'alert':
        icon = Icons.warning_rounded;
        iconColor = AppColors.error;
        break;
      case 'panic_alert':
        icon = Icons.warning_rounded;
        iconColor = AppColors.error;
        break;
      case 'journey_alert':
        icon = Icons.warning_rounded;
        iconColor = AppColors.error;
        break;
      case 'journey_start':
        icon = Icons.directions_walk;
        iconColor = AppColors.primary;
        break;
      case 'journey_safe_arrival':
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case 'report_status_update':
        icon = Icons.assignment_turned_in;
        iconColor = AppColors.primary;
        break;
      case 'system':
        icon = Icons.stars;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      color: notification.isSent ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isSent ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTimeAgo(notification.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        onTap: () {
          // Add navigation logic based on type later
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
