import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/di/injection_container.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
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
    return Column(
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('All Alerts', true),
              const SizedBox(width: 8),
              _buildFilterChip('Nearby', false),
              const SizedBox(width: 8),
              _buildFilterChip('Safety Tips', false),
              const SizedBox(width: 8),
              _buildFilterChip('Resolved', false),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              return _buildPostCard(
                author: 'SafeCitizen_${100 + index}',
                location: index % 2 == 0 ? 'Plaza Mataram' : 'Jl. Langko',
                time: '${index + 2}m ago',
                content: index % 2 == 0 
                  ? 'Security alert: Saw a group acting suspicious near the west exit. Stay safe everyone!'
                  : 'The lightning near the public park has been fixed. Clear visibility now.',
                empathyCount: 12 + index * 5,
                isAlert: index % 2 == 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required String author,
    required String location,
    required String time,
    required String content,
    required int empathyCount,
    required bool isAlert,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isAlert ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE),
                radius: 20,
                child: Icon(
                  Icons.person,
                  color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• $time',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAlert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ALERT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInteractionButton(Icons.favorite_border, '$empathyCount'),
              const SizedBox(width: 24),
              _buildInteractionButton(Icons.chat_bubble_outline, '8'),
              const SizedBox(width: 24),
              _buildInteractionButton(Icons.share_outlined, ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}
