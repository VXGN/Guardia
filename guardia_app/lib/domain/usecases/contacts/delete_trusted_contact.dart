import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class DeleteTrustedContact {
  final TrustedContactRepository repository;

  DeleteTrustedContact(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTrustedContact(id);
  }
}
