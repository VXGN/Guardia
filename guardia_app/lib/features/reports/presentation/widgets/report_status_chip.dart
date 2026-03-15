import 'package:flutter/material.dart';

class ReportStatusChip extends StatelessWidget {
  final String status;

  const ReportStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'RECEIVED':
        color = Colors.grey;
        break;
      case 'VERIFIED':
        color = Colors.blue;
        break;
      case 'ACTION_TAKEN':
        color = Colors.orange;
        break;
      case 'CLOSED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
