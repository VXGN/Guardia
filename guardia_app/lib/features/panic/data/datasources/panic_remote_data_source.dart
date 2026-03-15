import 'package:guardia_app/core/network/api_client.dart';

class PanicRemoteDataSource {
  final ApiClient apiClient;

  PanicRemoteDataSource({required this.apiClient});

  /// Starts a panic session on the backend.
  /// POST /panic/start
  Future<Map<String, dynamic>> startPanic({
    required double lat,
    required double lng,
  }) async {
    // TODO: Adjust endpoints with backend
    final response = await apiClient.post(
      '/panic/start',
      data: {
        'latitude': lat,
        'longitude': lng,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Updates user location during an active SOS session.
  /// POST /panic/update-location
  Future<void> updatePanicLocation({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    await apiClient.post(
      '/panic/update-location',
      data: {
        'session_id': sessionId,
        'latitude': lat,
        'longitude': lng,
      },
    );
  }

  /// Cancels an active panic session.
  /// POST /panic/cancel
  Future<void> cancelPanic({
    required String sessionId,
  }) async {
    await apiClient.post(
      '/panic/cancel',
      data: {
        'session_id': sessionId,
      },
    );
  }
}
