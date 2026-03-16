import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';

import 'package:guardia_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_event.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_state.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/features/reports/presentation/bloc/report/report_state.dart';
import 'package:guardia_app/di/injection_container.dart';
import 'package:guardia_app/features/panic/domain/usecases/set_emergency_pin.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(context, state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.background),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: AppColors.primary,
      centerTitle: false,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () => context.pushNamed('edit_profile'),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                context.read<ProfileBloc>().add(LoadProfileRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(
            user.fullName ?? 'Citizen',
            user.email ?? '-',
          ),
          const SizedBox(height: 32),
          _buildImpactCard(context),
          const SizedBox(height: 32),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsList(context),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 100),
        ],
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
        Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildImpactCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('impact_dashboard'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, reportState) {
            final reportCount = reportState.myReports.length;
            final level = (reportCount / 5).floor() + 1;
            final levelLabel = level >= 5
                ? 'Guardian'
                : (level >= 3 ? 'Defender' : 'Trusted');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Guardia Impact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildImpactItem(
                      Icons.verified_user,
                      'Level $level',
                      levelLabel,
                    ),
                    _buildImpactItem(Icons.report, '$reportCount', 'Reports'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImpactItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            Icons.history,
            'My Reports',
            onTap: () => context.pushNamed('my_reports'),
          ),
          const Divider(height: 1),
          _buildListTile(
            Icons.people_outline,
            'Trusted Contacts',
            onTap: () => context.pushNamed('trusted_contacts'),
          ),
          const Divider(height: 1),
          _buildListTile(
            Icons.notifications_active,
            'Notification Inbox',
            onTap: () => context.pushNamed('notifications'),
          ),
          const Divider(height: 1),
          _buildListTile(
            Icons.pin_outlined,
            'Emergency PIN',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Set / Update',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showSetPinSheet(context),
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            Icons.notifications_outlined,
            'Push Notifications',
            true,
            (val) {},
          ),
          const Divider(height: 1),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy'),
          const Divider(height: 1),
          _buildListTile(Icons.help_outline, 'Help & Support'),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      secondary: Icon(icon, color: AppColors.primary),
      activeThumbColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap ?? () {},
    );
  }

  Future<void> _showSetPinSheet(BuildContext pageContext) async {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;
    bool isLoading = false;
    String? errorText;

    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void onKeyTap(String key) {
              setSheetState(() {
                errorText = null;
                if (!isConfirming) {
                  if (key == '<') {
                    if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
                  } else if (pin.length < 4) {
                    pin += key;
                  }
                } else {
                  if (key == '<') {
                    if (confirmPin.isNotEmpty) confirmPin = confirmPin.substring(0, confirmPin.length - 1);
                  } else if (confirmPin.length < 4) {
                    confirmPin += key;
                    if (confirmPin.length == 4) {
                      if (confirmPin == pin) {
                        // Save
                        setSheetState(() => isLoading = true);
                        sl<SetEmergencyPin>()(pin: pin).then((_) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            const SnackBar(
                              content: Text('PIN darurat berhasil disimpan!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }).catchError((e) {
                          setSheetState(() {
                            isLoading = false;
                            isConfirming = false;
                            pin = '';
                            confirmPin = '';
                            errorText = 'Gagal menyimpan PIN. Coba lagi.';
                          });
                        });
                      } else {
                        setSheetState(() {
                          errorText = 'PIN tidak cocok. Coba lagi.';
                          isConfirming = false;
                          pin = '';
                          confirmPin = '';
                        });
                      }
                    }
                  }
                }
                if (!isConfirming && pin.length == 4) {
                  isConfirming = true;
                }
              });
            }

            final currentPin = isConfirming ? confirmPin : pin;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.pin_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isConfirming ? 'Konfirmasi PIN Darurat' : 'Set PIN Darurat',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isConfirming
                        ? 'Masukkan ulang PIN untuk konfirmasi'
                        : 'PIN ini digunakan untuk membatalkan SOS',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Pin dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < currentPin.length
                              ? AppColors.primary
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  if (errorText != null) ...
                  [
                    const SizedBox(height: 12),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    _buildPinKeypad(onKeyTap),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPinKeypad(void Function(String) onKeyTap) {
    final keys = ['1','2','3','4','5','6','7','8','9','<','0','✓'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        final isSpecial = key == '<' || key == '✓';
        return GestureDetector(
          onTap: () => key == '✓' ? null : onKeyTap(key),
          child: Container(
            decoration: BoxDecoration(
              color: isSpecial
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: isSpecial ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: isSpecial ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        context.goNamed('login');
      },
      icon: const Icon(Icons.logout, color: AppColors.error),
      label: const Text(
        'Sign Out',
        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
