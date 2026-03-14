import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class DeleteTrustedContact {

  DeleteTrustedContact(this.repository);
  final TrustedContactRepository repository;

  Future<Either<Failure, void>> call(String id) async {
    return repository.deleteTrustedContact(id);
  }
}
