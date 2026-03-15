import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/utils/phone_utils.dart';
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';

class CompanionCallPage extends StatelessWidget {
  final String companionId;

  const CompanionCallPage({super.key, required this.companionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanionBloc, CompanionState>(
      builder: (context, state) {
        TrustedContactEntity? contact;
        try {
          contact = state.contacts.firstWhere((c) => c.id == companionId);
        } catch (_) {
          contact = null;
        }
        
        final companionName = contact?.contactName ?? 'Companion $companionId';
        final companionPhone = contact?.contactPhone ?? '';

        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  _buildPulsingAvatar(),
                  const SizedBox(height: 32),
                  Text(
                    companionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    companionPhone.isNotEmpty ? companionPhone : 'Guardia Secure Call',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildCallActions(context, companionPhone),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Static circles to simulate pulse rings
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
        ),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF334155),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 60),
        ),
      ],
    );
  }

  Widget _buildCallActions(BuildContext context, String phoneNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(Icons.mic_off, 'Mute', Colors.white.withValues(alpha: 0.1)),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                if (phoneNumber.isNotEmpty) {
                  PhoneUtils.makePhoneCall(phoneNumber);
                }
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'CALL',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
