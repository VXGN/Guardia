import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  List<Permission> get _requiredPermissionList {
    if (kIsWeb) {
      // permission_handler does not implement contacts/storage on web.
      return [
        Permission.location,
        Permission.camera,
      ];
    }

    return [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.contacts,
    ];
  }

  Future<bool> _isGrantedOrUnsupported(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } on UnimplementedError {
      return true;
    }
  }

  /// Checks if all required permissions are granted.
  Future<bool> hasAllPermissions() async {
    final checks = await Future.wait(
      _requiredPermissionList.map(_isGrantedOrUnsupported),
    );
    return checks.every((isGranted) => isGranted);
  }

  /// Map of required permissions and their readable names/descriptions.
  Map<Permission, Map<String, String>> get requiredPermissions {
    final allPermissions = <Permission, Map<String, String>>{
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

    return Map.fromEntries(
      allPermissions.entries.where(
        (entry) => _requiredPermissionList.contains(entry.key),
      ),
    );
  }

  /// Requests all required permissions.
  Future<Map<Permission, PermissionStatus>> requestAll() async {
    return _requiredPermissionList.request();
  }
}
