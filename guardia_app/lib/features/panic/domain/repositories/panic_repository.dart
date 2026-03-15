import 'package:guardia_app/features/panic/domain/entities/panic_session_entity.dart';

abstract class PanicRepository {
  Future<PanicSessionEntity> startPanic({
    required double lat,
    required double lng,
  });

  Future<void> updatePanicLocation({
    required String sessionId,
    required double lat,
    required double lng,
  });

  Future<void> cancelPanic({
    required String sessionId,
    String? emergencyCode,
  });
}
