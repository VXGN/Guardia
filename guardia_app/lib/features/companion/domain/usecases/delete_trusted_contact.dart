import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart';

class DeleteTrustedContact {
  final TrustedContactRepository repository;

  DeleteTrustedContact(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteContact(id);
  }
}
