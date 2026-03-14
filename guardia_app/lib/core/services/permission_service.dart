import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Checks if all required permissions are granted.
  Future<bool> hasAllPermissions() async {
    final status = await Future.wait([
      Permission.location.status,
      Permission.camera.status,
      Permission.contacts.status,
      // For Media, we check storage on older Android and photos/videos on newer ones
      Permission.storage.status,
    ]);

    return status.every((s) => s.isGranted);
  }

  /// Map of required permissions and their readable names/descriptions.
  Map<Permission, Map<String, String>> get requiredPermissions => {
        Permission.location: {
          'title': 'Location',
          'description': 'To show your position on the map and find safe routes.',
        },
        Permission.camera: {
          'title': 'Camera',
          'description': 'To take photos/videos when reporting incidents.',
        },
        Permission.storage: {
          'title': 'Media & Storage',
          'description': 'To upload evidence and save safety tips.',
        },
        Permission.contacts: {
          'title': 'Contacts',
          'description': 'To easily add your Trusted Contacts.',
        },
      };

  /// Requests all required permissions.
  Future<Map<Permission, PermissionStatus>> requestAll() async {
    return await [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.contacts,
    ].request();
  }
}
