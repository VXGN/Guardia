import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/core/utils/phone_utils.dart';
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';
import 'package:guardia_app/features/companion/domain/entities/journey_session_entity.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';

class ActiveJourneyPage extends StatefulWidget {
  const ActiveJourneyPage({super.key});

  @override
  State<ActiveJourneyPage> createState() => _ActiveJourneyPageState();
}

class _ActiveJourneyPageState extends State<ActiveJourneyPage> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    // Journey status is already requested in CompanionStarted at app level.
    // Ensure timer starts if a journey is already active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<CompanionBloc>().state;
      if (state.activeJourney != null && _startTime == null) {
        _startTimer(state.activeJourney!.startedAt);
      }
    });
  }

  void _startTimer(DateTime startTime) {
    _startTime = startTime;
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
    return BlocConsumer<CompanionBloc, CompanionState>(
      listener: (context, state) {
        if (state.activeJourney != null && _startTime == null) {
          _startTimer(state.activeJourney!.startedAt);
        }
        
        if (state.activeJourney == null && _startTime != null) {
          // Journey was ended
          _elapsedTimer?.cancel();
          _startTime = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journey completed. Arrived safely! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          context.goNamed('home');
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
          context.read<CompanionBloc>().add(const CompanionResetError());
        }

        if (state.alertSent) {
          _showSosSentDialog(context);
          context.read<CompanionBloc>().add(const CompanionResetAlert());
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (state.activeJourney != null) {
          return _buildActiveJourneyUI(context, state, state.activeJourney!);
        }
        
        return _buildNoActiveJourneyUI(context);
      },
    );
  }

  Widget _buildActiveJourneyUI(BuildContext context, CompanionState state, JourneySessionEntity journey) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Active Journey', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Timer Card
            _buildStatusCard(journey),
            const SizedBox(height: 20),
            // Companion Contacts
            _buildCompanionsCard(journey, state),
            const SizedBox(height: 20),
            // Quick actions
            _buildQuickActions(context, journey),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, state, journey),
    );
  }

  Widget _buildStatusCard(JourneySessionEntity journey) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text('Journey Active', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Your companions can see your location', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
          const SizedBox(height: 20),
          Text(
            _formatDuration(_elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text('Elapsed Time', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCompanionsCard(JourneySessionEntity journey, CompanionState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monitoring Companions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...journey.contactIds.map((contactId) {
            TrustedContactEntity? contact;
            try {
              contact = state.contacts.firstWhere((c) => c.id == contactId);
            } catch (_) {
              contact = null;
            }

            final displayName = contact?.contactName ?? 'Companion';
            final displayPhone = contact?.contactPhone ?? '';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(displayPhone.isNotEmpty ? displayPhone : 'ID: $contactId', style: TextStyle(color: Colors.grey[600])),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_outlined, color: AppColors.primary, size: 22),
                    onPressed: () => context.pushNamed('companion_chat', pathParameters: {'companionId': contactId}),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 22),
                    onPressed: () {
                      if (displayPhone.isNotEmpty) {
                        PhoneUtils.makePhoneCall(displayPhone);
                      } else {
                        context.pushNamed('companion_call', pathParameters: {'companionId': contactId});
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, JourneySessionEntity journey) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_location,
            label: 'Share Location',
            color: AppColors.primary,
            onTap: () {
              context.read<CompanionBloc>().add(const CompanionLocationShared());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location shared to companions.')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.warning_rounded,
            label: 'Trigger Alert',
            color: AppColors.warning,
            onTap: () => _showAlertConfirmDialog(context, journey),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, CompanionState state, JourneySessionEntity journey) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: state.isEndingJourney 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () => _showFinishDialog(context, journey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Safe Arrival ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveJourneyUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Journey Tracking'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text('No active journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Start a journey from the Companion screen to track it here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.goNamed('home'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Go to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog(BuildContext context, JourneySessionEntity journey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Safe Arrival'),
        content: const Text('Are you sure you want to mark this journey as completed?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CompanionBloc>().add(const JourneyEndRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAlertConfirmDialog(BuildContext context, JourneySessionEntity journey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trigger Alert'),
        content: const Text('This will send an emergency alert to all your watching companions immediately.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CompanionBloc>().add(const CompanionAlertTriggered());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🚨 Alert sent to companions!'), backgroundColor: AppColors.error),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Send Alert', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
