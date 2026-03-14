import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/journey.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_bloc.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_event.dart';
import 'package:guardia_app/presentation/bloc/journey/journey_state.dart';
import 'package:guardia_app/domain/entities/journey.dart';

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
    context.read<JourneyBloc>().add(JourneyLoadActiveRequested());
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JourneyBloc, JourneyState>(
      listener: (context, state) {
        if (state is JourneyActive && _startTime == null) {
          _startTimer(state.journey.startedAt);
        }
        if (state is JourneyCompleted) {
          _elapsedTimer?.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perjalanan selesai. Selamat tiba dengan selamat! 🎉'), backgroundColor: AppColors.success),
          );
          context.go('/home');
        }
        if (state is JourneyCancelled) {
          _elapsedTimer?.cancel();
          context.go('/home');
        }
      },
      builder: (context, state) {
        if (state is JourneyLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is JourneyActive) {
          return _buildActiveJourneyUI(context, state.journey);
        }
        if (state is JourneyInitial) {
          return _buildNoActiveJourneyUI(context);
        }
        if (state is JourneyError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildActiveJourneyUI(BuildContext context, Journey journey) {
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
            if (journey.contacts.isNotEmpty) ...[
              _buildCompanionsCard(journey),
              const SizedBox(height: 20),
            ],
            // Quick actions
            _buildQuickActions(context, journey),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, journey),
    );
  }

  Widget _buildStatusCard(Journey journey) {
    final bool hasDestination = journey.destinationLat != null && journey.destinationLng != null;
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
          Text('Your companion can see your location', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
          const SizedBox(height: 20),
          Text(
            _formatDuration(_elapsed),
            style: TextStyle(
            fontWeight: FontWeight.w300,
          )),
          ),
          const SizedBox(height: 4),
          Text('Elapsed Time', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          if (hasDestination) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Destination set at ${journey.destinationLat!.toStringAsFixed(4)}, ${journey.destinationLng!.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanionsCard(Journey journey) {
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
          ...journey.contacts.map((contact) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                title: Text(contact.contactName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(contact.contactPhone, style: TextStyle(color: Colors.grey[600])),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Watching', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Journey journey) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_location,
            label: 'Share Location',
            color: AppColors.primary,
            onTap: () {
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

  Widget _buildBottomActions(BuildContext context, Journey journey) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context, journey),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel Journey', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
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
            Text('Start a journey from the Home screen to track it here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Go to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog(BuildContext context, Journey journey) {
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
              context.read<JourneyBloc>().add(JourneyFinishRequested(journey.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Journey journey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Journey'),
        content: const Text('This will stop location sharing with your companions. Are you sure?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<JourneyBloc>().add(JourneyCancelRequested(journey.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Journey', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAlertConfirmDialog(BuildContext context, Journey journey) {
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
