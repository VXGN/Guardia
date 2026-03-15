import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';

class UpdatePanicLocation {
  final PanicRepository repository;

  UpdatePanicLocation(this.repository);

  Future<void> call({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    return repository.updatePanicLocation(
      sessionId: sessionId,
      lat: lat,
      lng: lng,
    );
  }
}
