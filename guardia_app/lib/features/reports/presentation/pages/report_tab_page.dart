import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/di/injection_container.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
import '../../domain/entities/report_entity.dart';
import '../../../../presentation/pages/reports/my_reports_page.dart';

class ReportTabPage extends StatelessWidget {
  const ReportTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>()..add(ReportStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ruang Aman'),
          centerTitle: true,
          elevation: 0,
          actions: [
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state.currentTab == ReportTab.myReports && !state.isCreatingReport) {
                  return IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: () => context.pushNamed('report_incident'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            const _ReportTabHeader(),
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state.currentTab == ReportTab.community) {
                    return const _CommunityFeed();
                  } else {
                    return const MyReportsPage(isEmbedded: true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTabHeader extends StatelessWidget {
  const _ReportTabHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              _TabButton(
                title: 'Global Feed',
                isSelected: state.currentTab == ReportTab.community,
                onTap: () => context.read<ReportBloc>().add(const ReportTabChanged(0)),
              ),
              const SizedBox(width: 8),
              _TabButton(
                title: 'My Reports',
                isSelected: state.currentTab == ReportTab.myReports,
                onTap: () => context.read<ReportBloc>().add(const ReportTabChanged(1)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state.globalReportsStatus == ReportStatus.loading && state.globalReports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.globalReportsStatus == ReportStatus.failure && state.globalReports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.errorMessage}'),
                TextButton(
                  onPressed: () => context.read<ReportBloc>().add(GlobalReportsRequested()),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final reports = state.globalReports.where((report) {
          // Status filtering in community feed might be different, 
          // but for now we'll stick to category filtering.
          final matchesCategory = state.categoryFilter == 'All' || 
              report.category.toLowerCase() == state.categoryFilter.toLowerCase();
          return matchesCategory;
        }).toList();

        return Column(
          children: [
            _buildCategoryFilter(context, state),
            Expanded(
              child: reports.isEmpty
                ? const Center(child: Text('No reports match your filter.'))
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<ReportBloc>().add(GlobalReportsRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _SocialReportCard(report: report);
                      },
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ReportState state) {
    final categories = [
      'All', 
      'Harassment', 
      'Suspicious Activity', 
      'Poor Lighting', 
      'Verbal Abuse', 
      'Medical Issue', 
      'Other'
    ];
    
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = state.categoryFilter.toLowerCase() == cat.toLowerCase();
          return GestureDetector(
            onTap: () {
              context.read<ReportBloc>().add(ReportFilterChanged(category: cat));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                backgroundColor: isSelected ? AppColors.primary : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _SocialReportCard extends StatelessWidget {
  final ReportEntity report;

  const _SocialReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(report.timestamp);
    final isAlert = report.category.toLowerCase().contains('suspicious') || 
                    report.category.toLowerCase().contains('theft') ||
                    report.category.toLowerCase().contains('harassment');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    report.isAnonymous ? Icons.shield_outlined : Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.isAnonymous || report.userId == null 
                            ? 'Anonymous Member' 
                            : 'Member_${report.userId!.length > 5 ? report.userId!.substring(0, 5) : report.userId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (report.locationLabel.isNotEmpty) ...[
                            const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                report.locationLabel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (report.mediaUrls.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(report.mediaUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.description ?? 'No description provided',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _SocialButton(
                  icon: Icons.favorite_border,
                  label: '24',
                  onTap: () {},
                ),
                _SocialButton(
                  icon: Icons.chat_bubble_outline,
                  label: '8',
                  onTap: () {},
                ),
                _SocialButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
