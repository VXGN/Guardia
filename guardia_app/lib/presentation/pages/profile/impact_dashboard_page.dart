import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class ImpactDashboardPage extends StatelessWidget {
  const ImpactDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Impact', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLevelCard(),
            const SizedBox(height: 32),
            const Text('Recent Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBadgesGrid(),
            const SizedBox(height: 32),
            const Text('How to earn points?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildEarningGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
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
          const Text(
            'Level 2: Trusted Citizen',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 0.8, // 80% to next level
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 8,
                ),
              ),
              Column(
                children: [
                   const Text('250', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                   Text('Points', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '50 points to Level 3',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildBadgeCard(Icons.eco, 'Eco-Traveler', 'Completed 5 green routes', AppColors.success),
        _buildBadgeCard(Icons.shield, 'First Responder', 'Reported 1 verified incident', AppColors.warning),
        _buildBadgeCard(Icons.map, 'Explorer', 'Navigated 50km safely', AppColors.primary),
        _buildBadgeCard(Icons.group, 'Guardian', 'Added 3 trusted companions', AppColors.secondary),
      ],
    );
  }

  Widget _buildBadgeCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget _buildEarningGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildGuideRow(Icons.report_problem, 'Report an accurate incident', '+50 pts'),
          const Divider(),
          _buildGuideRow(Icons.directions_walk, 'Use an eco-friendly safe route', '+20 pts'),
          const Divider(),
          _buildGuideRow(Icons.check_circle, 'Verify a community alert', '+10 pts'),
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
