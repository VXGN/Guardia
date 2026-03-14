import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ruang Aman',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'community_add_fab',
        onPressed: () => context.push('/report'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            color: Colors.black.withValues(alpha: 0.02),
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
                          'â€¢ $time',
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
