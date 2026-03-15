import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';

class CancelPanicAction {
  final PanicRepository repository;

  CancelPanicAction(this.repository);

  Future<void> call({
    required String sessionId,
    String? emergencyCode,
  }) async {
    return repository.cancelPanic(
      sessionId: sessionId,
      emergencyCode: emergencyCode,
    );
  }
}
