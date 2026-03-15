import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_state.dart';
import '../widgets/report_status_chip.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.detailStatus == ReportStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = state.selectedReport;
          if (report == null) {
            return const Center(child: Text('Report not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.category.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ReportStatusChip(status: report.status),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Time',
                  value: DateFormat('dd MMM yyyy, HH:mm').format(report.timestamp),
                ),
                const SizedBox(height: 16),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: report.locationLabel.isNotEmpty ? report.locationLabel : 'Nearby Area',
                ),
                if (report.description != null && report.description!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    report.description!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
                const SizedBox(height: 32),
                const Text('Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (report.mediaUrls.isEmpty)
                  const Text('No media attached.', style: TextStyle(color: Colors.grey))
                else
                  Text('${report.mediaUrls.length} file(s) attached.'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
