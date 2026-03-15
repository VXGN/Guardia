import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_state.dart';

class ImpactDashboardPage extends StatelessWidget {
  const ImpactDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Impact', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, reportState) {
            final reportCount = reportState.myReports.length;
            final level = (reportCount / 5).floor() + 1;
            final levelName = level >= 5 ? 'Guardian' : (level >= 3 ? 'Defender' : 'Trusted Citizen');
            final nextLevelThreshold = level * 5;
            final progress = (reportCount % 5) / 5;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLevelCard(level, levelName, reportCount, nextLevelThreshold, progress),
                const SizedBox(height: 32),
                const Text('Recent Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBadgesGrid(context),
                const SizedBox(height: 32),
                const Text('How to level up?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildEarningGuide(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(int level, String name, int reportCount, int threshold, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Level $level: $name',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 8,
                ),
              ),
              Column(
                children: [
                   Text('$reportCount', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                   Text('Reports', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '${threshold - reportCount} reports to Level ${level + 1}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildBadgeCard(Icons.eco, 'Eco-Traveler', 'Completed 5 green routes', AppColors.success, context),
        _buildBadgeCard(Icons.shield, 'First Responder', 'Reported 1 verified incident', AppColors.warning, context),
        _buildBadgeCard(Icons.map, 'Explorer', 'Navigated 50km safely', AppColors.primary, context),
        _buildBadgeCard(Icons.group, 'Guardian', 'Added 3 trusted companions', AppColors.secondary, context),
      ],
    );
  }

  Widget _buildBadgeCard(IconData icon, String title, String subtitle, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600]), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEarningGuide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildGuideRow(Icons.report_problem, 'Report an accurate incident', '+1 credit'),
          const Divider(),
          _buildGuideRow(Icons.check_circle, 'Verify a community alert', '+1 credit'),
        ],
      ),
    );
  }

  Widget _buildGuideRow(IconData icon, String title, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 14))),
          Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
        ],
      ),
    );
  }
}
