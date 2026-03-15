import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';

class ActiveNavigationOverlay extends StatelessWidget {
  final RouteOptionEntity? route;
  final VoidCallback onFinish;

  const ActiveNavigationOverlay({
    required this.onFinish,
    this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final firstStep = (route?.steps.isNotEmpty ?? false) ? route!.steps.first : null;
    final instruction = firstStep?.instruction ?? 'Proceed to route';
    final distanceText = firstStep != null 
        ? (firstStep.distanceMeters < 1000 
            ? '${firstStep.distanceMeters}m' 
            : '${(firstStep.distanceMeters / 1000).toStringAsFixed(1)}km')
        : '---';
        
    final totalDistanceKm = ((route?.distanceMeters ?? 0) / 1000).toStringAsFixed(1);
    final totalDurationMin = ((route?.durationSeconds ?? 0) / 60).toStringAsFixed(0);
    final safetyScore = (route?.safetyScore ?? 0).toStringAsFixed(0);

    return Stack(
      children: [
        // Top Instruction Banner
        Positioned(
          top: 56,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getInstructionIcon(firstStep?.modifier),
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In $distanceText',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        instruction,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Warning Popup (Mocked Proximity Alert)
        Positioned(
          top: 170,
          left: 40,
          right: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Subtle orange/amber
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Entering High Risk Zone - Stay Alert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Stats & Finish Button
        Positioned(
          bottom: 100, // Above bottom nav
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol('$totalDurationMin min', 'Remaining'),
                    _buildStatCol('$totalDistanceKm km', 'Distance'),
                    _buildStatCol(safetyScore, 'Safety Score', isSafety: true),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: const Text(
                      'FINISH NAVIGATION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getInstructionIcon(String? modifier) {
    if (modifier == null) return Icons.navigation;
    if (modifier.contains('left')) return Icons.turn_left;
    if (modifier.contains('right')) return Icons.turn_right;
    if (modifier.contains('sharp_left')) return Icons.turn_sharp_left;
    if (modifier.contains('sharp_right')) return Icons.turn_sharp_right;
    if (modifier.contains('slight_left')) return Icons.turn_slight_left;
    if (modifier.contains('slight_right')) return Icons.turn_slight_right;
    if (modifier.contains('straight')) return Icons.straight;
    return Icons.navigation;
  }

  Widget _buildStatCol(String value, String label, {bool isSafety = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSafety ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
