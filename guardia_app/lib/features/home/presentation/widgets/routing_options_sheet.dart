import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class RoutingOptionsSheet extends StatelessWidget {
  final VoidCallback onStart;

  const RoutingOptionsSheet({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Recommended Routes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Fastest Route Card
          _buildRouteCard(
            title: 'Fastest Route',
            duration: '12 min',
            distance: '3.4 km',
            isSelected: false,
            onTap: () {},
          ),
          
          const SizedBox(height: 16),

          // Safe Guardia Card (Selected by Default)
          _buildRouteCard(
            title: 'Safe Guardia',
            duration: '14 min',
            distance: '3.8 km',
            isSelected: true,
            isSafe: true,
            features: [
              'High Lighting',
              'Monitored Zone',
              'Avoids 3 Risk Zones'
            ],
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Start Button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'START NAVIGATION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRouteCard({
    required String title,
    required String duration,
    required String distance,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isSafe = false,
    List<String>? features,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? (isSafe ? const Color(0xFFF0FDFA) : const Color(0xFFF8FAFC)) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? (isSafe ? AppColors.secondary : AppColors.primary) : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (isSafe ? AppColors.secondary : AppColors.primary).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isSafe)
                      const Icon(Icons.verified_user, color: AppColors.secondary, size: 20),
                    if (isSafe) const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSafe ? AppColors.secondary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSafe ? AppColors.secondary.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSafe ? AppColors.secondary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (features != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((f) => _buildFeatureTag(f)).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 12, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
