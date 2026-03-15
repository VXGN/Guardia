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

  /// Cancels an active panic session.
  /// POST /api/panic/cancel
  Future<void> cancelPanic({
    required String sessionId,
    String? emergencyCode,
  }) async {
    await apiClient.post(
      Endpoints.cancelPanic,
      data: {
        'session_id': sessionId,
        if (emergencyCode != null && emergencyCode.trim().isNotEmpty)
          'emergency_code': emergencyCode.trim(),
      },
    );
  }
}
