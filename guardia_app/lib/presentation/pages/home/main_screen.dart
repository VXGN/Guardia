import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/panic/presentation/bloc/panic/panic_bloc.dart';
import 'package:guardia_app/features/panic/presentation/bloc/panic/panic_event.dart';
import 'package:guardia_app/features/panic/presentation/bloc/panic/panic_state.dart';
import 'package:guardia_app/presentation/pages/home/home_page.dart';
import 'package:guardia_app/presentation/pages/journey/companion_setup_page.dart';
import 'package:guardia_app/features/profile/presentation/pages/profile_page.dart';
import 'package:guardia_app/features/reports/presentation/pages/report_tab_page.dart';
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';
import 'package:guardia_app/features/panic/presentation/widgets/sos_active_overlay.dart';
import 'package:guardia_app/features/panic/presentation/widgets/sos_countdown_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of standard pages for the bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const CompanionSetupPage(),
    const ReportTabPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fetch emergency PIN hash for local verification during SOS countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PanicBloc>().add(PanicLoadEmergencyPin());
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSosPressed() {
    context.read<PanicBloc>().add(PanicButtonPressed());
  }

  void _showSosSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('SOS Sent'),
          ],
        ),
        content: const Text('Your location and emergency alerts have been successfully sent to all trusted contacts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PanicBloc, PanicState>(
          listener: (context, state) {
            if (state.status == PanicStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
        BlocListener<PanicBloc, PanicState>(
          listenWhen: (previous, current) =>
              previous.status != PanicStatus.active &&
              current.status == PanicStatus.active,
          listener: (context, _state) {
            context.read<CompanionBloc>().add(const CompanionAlertTriggered());
          },
        ),
        BlocListener<CompanionBloc, CompanionState>(
          listenWhen: (previous, current) => !previous.alertSent && current.alertSent,
          listener: (context, state) {
            _showSosSentDialog(context);
            context.read<CompanionBloc>().add(const CompanionResetAlert());
          },
        ),
      ],
      child: BlocBuilder<PanicBloc, PanicState>(
        builder: (context, state) {
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
                        _buildNavItem(icon: Icons.people_outline, label: 'Companions', index: 1),
                        
                        const SizedBox(width: 48), // Space for the SOS FAB
                        
                        _buildNavItem(icon: Icons.assignment_outlined, label: 'Reports', index: 2),
                        _buildNavItem(icon: Icons.person_outline, label: 'Profile', index: 3),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Overlays driven by PanicBloc state
              if (state.status == PanicStatus.countingDown)
                SosCountdownOverlay(
                  onCancel: () {
                    context.read<PanicBloc>().add(PanicResetToIdle());
                  },
                  onConfirm: () {
                    context.read<PanicBloc>().add(PanicCountdownFinished());
                  },
                  onPinCompleted: (pin) async {
                    final completer = Completer<bool>();
                    context.read<PanicBloc>().add(
                      PanicCountdownPinSubmitted(
                        emergencyCode: pin,
                        result: completer,
                      ),
                    );
                    return completer.future;
                  },
                ),
                
              if (state.status == PanicStatus.active || 
                  state.status == PanicStatus.starting || 
                  state.status == PanicStatus.updatingLocation)
                SosActiveOverlay(
                  onFinish: () {
                    context.read<PanicBloc>().add(PanicCancelRequested());
                  },
                ),
                
              // Loading indicator for background operations (starting/cancelling)
              if (state.status == PanicStatus.starting || state.status == PanicStatus.cancelling)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
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



