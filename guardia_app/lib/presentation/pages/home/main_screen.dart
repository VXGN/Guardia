import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/presentation/pages/home/community_feed_page.dart';
import 'package:guardia_app/presentation/pages/home/home_page.dart';
import 'package:guardia_app/presentation/pages/journey/companion_setup_page.dart';
import 'package:guardia_app/presentation/pages/reports/my_reports_page.dart';
import 'package:guardia_app/presentation/widgets/panic/sos_active_overlay.dart';
import 'package:guardia_app/presentation/widgets/panic/sos_countdown_overlay.dart';

enum SosStatus { idle, countdown, active }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  SosStatus _sosStatus = SosStatus.idle;

  // List of standard pages for the bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const CommunityFeedPage(),
    const MyReportsPage(),
    const CompanionSetupPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSosPressed() {
    setState(() {
      _sosStatus = SosStatus.countdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true, // Allows body to extend behind the BottomAppBar
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            padding: const EdgeInsets.all(4), // White border effect ring
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: FloatingActionButton(
              heroTag: 'sos_fab',
              onPressed: _onSosPressed,
              backgroundColor: AppColors.error,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            clipBehavior: Clip.antiAlias,
            elevation: 8,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.map_outlined, label: 'Home', index: 0),
                  _buildNavItem(icon: Icons.shield_outlined, label: 'Safety Zone', index: 1),
                  
                  const SizedBox(width: 48), // Space for the SOS FAB
                  
                  _buildNavItem(icon: Icons.assignment_outlined, label: 'Reports', index: 2),
                  _buildNavItem(icon: Icons.people_outline, label: 'Companion', index: 3),
                ],
              ),
            ),
          ),
        ),
        if (_sosStatus == SosStatus.countdown)
          SosCountdownOverlay(
            onCancel: () {
              setState(() {
                _sosStatus = SosStatus.idle;
              });
            },
            onConfirm: () {
              setState(() {
                _sosStatus = SosStatus.active;
              });
            },
          ),
        if (_sosStatus == SosStatus.active)
          SosActiveOverlay(
            onFinish: () {
              setState(() {
                _sosStatus = SosStatus.idle;
              });
            },
          ),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.dotInactive;

    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}



