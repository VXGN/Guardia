import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/reports/domain/entities/report_entity.dart';


class ReportDetailPage extends StatelessWidget {
  final ReportEntity report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumStatusHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIncidentMetadataGrid(),
                  const SizedBox(height: 40),
                  const Text(
                    'Tracking Progress',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Real-time updates from authorities and responders.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildAdvancedTimeline(),
                  const SizedBox(height: 40),
                  _buildEvidenceSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusHeader() {
    final statusColor = _getStatusColor(report.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.02),
            Colors.white,
          ],
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(report.status),
              color: statusColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              report.status.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Incident #${report.id.length > 8 ? report.id.substring(0, 8).toUpperCase() : report.id.toUpperCase()}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reported on ${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}',
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentMetadataGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incident Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 4),
                Text(
                  'Full context of the reported issue.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
            if (report.isAnonymous)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_off_outlined, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      'ANONYMOUS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildMetadataCard(Icons.category_rounded, 'TYPE', report.category),
            _buildMetadataCard(Icons.location_on_rounded, 'LOCATION', report.locationLabel),
            _buildMetadataCard(Icons.event_rounded, 'DATE', '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}'),
            _buildMetadataCard(Icons.access_time_filled_rounded, 'TIME', '${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'DESCRIPTION',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Text(
            report.description ?? 'No description provided.',
            style: const TextStyle(color: Color(0xFF334155), fontSize: 15, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTimeline() {
    // ReportEntity doesn't have statusLogs yet, showing a simplified version
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text('Current status: ${report.status}. Updates pending...', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidence & Media',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.none),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_search_rounded, color: Color(0xFF94A3B8), size: 32),
                SizedBox(width: 12),
                Text(
                  'No media attachments provided.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.blue;
      case 'verified':
        return AppColors.primary;
      case 'in_progress':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Icons.assignment_turned_in_outlined;
      case 'verified':
        return Icons.verified_user_outlined;
      case 'in_progress':
        return Icons.sync;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
