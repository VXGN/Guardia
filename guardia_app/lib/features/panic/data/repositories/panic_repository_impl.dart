import 'package:guardia_app/features/panic/data/datasources/panic_remote_data_source.dart';
import 'package:guardia_app/features/panic/domain/entities/panic_session_entity.dart';
import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';

class PanicRepositoryImpl implements PanicRepository {
  final PanicRemoteDataSource remoteDataSource;

  PanicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PanicSessionEntity> startPanic({
    required double lat,
    required double lng,
  }) async {
    try {
      final responseData = await remoteDataSource.startPanic(lat: lat, lng: lng);
      // Assuming response structure: { "data": { "session_id": "...", "user_id": "...", ... } }
      final data = responseData['data'] as Map<String, dynamic>;
      return PanicSessionEntity(
        id: data['session_id'] as String,
        userId: data['user_id'] as String,
        lastLatitude: (data['latitude'] as num).toDouble(),
        lastLongitude: (data['longitude'] as num).toDouble(),
        startedAt: DateTime.parse(data['started_at'] as String),
        isActive: data['status'] == 'ACTIVE',
      );
    } catch (e) {
      print('Falling back to mock Panic session due to error: $e');
      return PanicSessionEntity(
        id: 'mock_panic_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'mock_user_123',
        lastLatitude: lat,
        lastLongitude: lng,
        startedAt: DateTime.now(),
        isActive: true,
      );
    }
  }

  @override
  Future<void> updatePanicLocation({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    try {
      print('Repository: Updating Panic Location for session $sessionId -> Lat=$lat, Lng=$lng');
      if (sessionId.startsWith('mock_')) {
        print('Repository: [MOCK MODE] Simulating location update success.');
        return;
      }
      await remoteDataSource.updatePanicLocation(
        sessionId: sessionId,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      print('Repository error updating panic location: $e');
    }
  }

  @override
  Future<void> cancelPanic({
    required String sessionId,
    String? emergencyCode,
  }) async {
    try {
      if (sessionId.startsWith('mock_')) return;
      await remoteDataSource.cancelPanic(
        sessionId: sessionId,
        emergencyCode: emergencyCode,
      );
    } catch (e) {
      print('Network error cancelling panic: $e');
    }
  }
}
