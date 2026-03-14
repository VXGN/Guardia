import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/core/services/permission_service.dart';
import 'package:guardia_app/di/injection_container.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  final _permissionService = sl<PermissionService>();
  bool _isRequesting = false;

  Future<void> _handlePermissions() async {
    setState(() => _isRequesting = true);

    try {
      final results = await _permissionService.requestAll();
      
      // If location is denied forever, we might need to show a dialog to open settings
      if (results[Permission.location]?.isPermanentlyDenied ?? false) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Required'),
              content: const Text(
                'Guardia needs location access to function. Please enable it in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Settings'),
                ),
              ],
            ),
          );
        }
      }

      // Check if essential permissions (Location) are granted to proceed
      if (results[Permission.location]?.isGranted ?? false) {
        if (mounted) context.goNamed('home');
      } else {
        // Optional: show a snackbar saying essential permissions are needed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is essential for Guardia.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsMap = _permissionService.requiredPermissions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.security_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Safety First',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'To provide the best protection, Guardia needs access to a few features on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView(
                  children: permissionsMap.entries.map((entry) {
                    final icon = _getIconForPermission(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value['description']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _handlePermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Allow Access',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPermission(Permission p) {
    if (p == Permission.location) return Icons.location_on_outlined;
    if (p == Permission.camera) return Icons.camera_alt_outlined;
    if (p == Permission.storage) return Icons.perm_media_outlined;
    if (p == Permission.contacts) return Icons.contacts_outlined;
    return Icons.settings_outlined;
  }
}
