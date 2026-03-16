import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';

class PanicRemoteDataSource {
  final ApiClient apiClient;

  PanicRemoteDataSource({required this.apiClient});

  /// Starts a panic session on the backend.
  /// POST /api/panic/trigger
  Future<Map<String, dynamic>> startPanic({
    required double lat,
    required double lng,
  }) async {
    final response = await apiClient.post(
      Endpoints.triggerPanic,
      data: {
        'latitude': lat,
        'longitude': lng,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Updates user location during an active SOS session.
  /// POST /api/panic/update-location
  Future<void> updatePanicLocation({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    await apiClient.post(
      Endpoints.updatePanicLocation,
      data: {
        'session_id': sessionId,
        'latitude': lat,
        'longitude': lng,
      },
    );
  }

  /// Fetches the user's emergency PIN hash for local verification.
  /// GET /api/panic/emergency-pin-hash
  Future<String?> fetchEmergencyPinHash() async {
    final response = await apiClient.get(Endpoints.emergencyPinHash);
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>?;
    if (inner == null || inner['has_pin'] != true) return null;
    return inner['emergency_pin_hash'] as String?;
  }

  /// Cancels an active panic session.
  /// POST /api/panic/cancel
  Future<void> cancelPanic({
    String? sessionId,
    String? emergencyCode,
  }) async {
    await apiClient.post(
      Endpoints.cancelPanic,
      data: {
        if (sessionId != null && sessionId.trim().isNotEmpty)
          'session_id': sessionId.trim(),
        if (emergencyCode != null && emergencyCode.trim().isNotEmpty)
          'emergency_code': emergencyCode.trim(),
      },
    );
  }
}
