import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/app_notification.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications for UI presentation
    final List<AppNotification> notifications = [
      AppNotification(
        id: '1',
        title: 'Community Alert',
        body: 'A flood warning has been issued near Monjok.',
        notificationType: 'alert',
        isSent: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: '2',
        title: 'Report Verified',
        body: 'Your report regarding broken streetlights has been verified.',
        notificationType: 'report_status_update',
        isSent: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: '3',
        title: 'Impact Level Up!',
        body: 'Congratulations! You have reached Level 2: Trusted Citizen.',
        notificationType: 'system',
        isSent: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(notification);
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
