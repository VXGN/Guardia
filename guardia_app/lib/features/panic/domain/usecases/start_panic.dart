import 'package:guardia_app/features/panic/domain/entities/panic_session_entity.dart';
import 'package:guardia_app/features/panic/domain/repositories/panic_repository.dart';

class StartPanic {
  final PanicRepository repository;

  StartPanic(this.repository);

  Future<PanicSessionEntity> call({
    required double lat,
    required double lng,
  }) async {
    return repository.startPanic(lat: lat, lng: lng);
  }
}
