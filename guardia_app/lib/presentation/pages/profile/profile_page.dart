import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated && state.user != null) {
            final user = state.user!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user.name ?? 'Citizen', user.email),
                  const SizedBox(height: 32),
                  _buildImpactCard(context),
                  const SizedBox(height: 32),
                  const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSettingsList(context),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 100), // Padding for bottom navbar
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImpactCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/impact_dashboard'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Guardia Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImpactItem(Icons.verified_user, 'Level 2', 'Trusted'),
                _buildImpactItem(Icons.eco, '250', 'Impact Pts'),
                _buildImpactItem(Icons.report, '12', 'Reports'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(Icons.history, 'My Reports', onTap: () => context.push('/my_reports')),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildListTile(Icons.notifications_active, 'Notification Inbox', onTap: () => context.push('/notifications')),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildSwitchTile(Icons.notifications_outlined, 'Push Notifications', true),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildListTile(Icons.language, 'Language', trailing: const Text('English', style: TextStyle(color: Colors.grey))),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildSwitchTile(Icons.dark_mode_outlined, 'Dark Mode', false),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy'),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildListTile(Icons.help_outline, 'Help & Support'),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value) {
    return SwitchListTile(
      value: value,
      onChanged: (val) {},
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      secondary: Icon(icon, color: AppColors.primary),
      activeThumbColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        context.goNamed('login');
      },
      icon: const Icon(Icons.logout, color: AppColors.error),
      label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
