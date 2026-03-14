import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/incident_report.dart';

class MyReportsPage extends StatefulWidget {
  final bool isEmbedded;

  const MyReportsPage({super.key, this.isEmbedded = false});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  @override
  void initState() {
    super.initState();
    // context.read<ReportBloc>().add(LoadMyReportsRequested()); // Disabled API call
  }

  // Hardcoded mockup data to bypass API
  final List<IncidentReport> _mockReports = [
    IncidentReport(
      id: 'REP-001-2024',
      incidentType: 'Harassment',
      incidentAt: DateTime.now().subtract(const Duration(days: 2)),
      latitude: -8.5833,
      longitude: 116.1167,
      latitudeBlurred: -8.58,
      longitudeBlurred: 116.12,
      isAnonymous: false,
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      media: const [],
      statusLogs: const [],
      locationLabel: 'Kebon Roek, Mataram',
      description: 'Being harassed by a group of individuals while waiting for public transport.',
    ),
    IncidentReport(
      id: 'REP-002-2024',
      incidentType: 'Poor Lighting',
      incidentAt: DateTime.now().subtract(const Duration(days: 5)),
      latitude: -8.5900,
      longitude: 116.1000,
      latitudeBlurred: -8.59,
      longitudeBlurred: 116.10,
      isAnonymous: true,
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      media: const [],
      statusLogs: const [],
      locationLabel: 'Jalan Udayana',
      description: 'Street lights are broken in this area for more than a week, making it dangerous at night.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildBody();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _mockReports.isEmpty 
            ? _buildEmptyState() 
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _mockReports.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => context.pushNamed('report_detail', extra: _mockReports[index]),
                    child: _buildReportCard(_mockReports[index]),
                  );
                },
              ),
        ),
      ],
    );
  }


  Widget _buildFilterBar() {
    final filters = ['All', 'Received', 'In Progress', 'Resolved'];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0; // Static mockup
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              backgroundColor: isSelected ? AppColors.primary : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.description_outlined, size: 64, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Reports Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your incident history will appear here.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(IncidentReport report) {
    final statusColor = _getStatusColor(report.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      report.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${report.incidentAt.day}/${report.incidentAt.month}/${report.incidentAt.year}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.incidentType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                report.locationLabel ?? 'Unknown Location',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.description ?? 'No details provided.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'VIEW PROGRESS',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
            ],
          ),
        ],
      ),
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
        return const Color(0xFF94A3B8);
    }
  }
}
