import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart';

class AddTrustedContact {
  final TrustedContactRepository repository;

  AddTrustedContact(this.repository);

  Future<Either<Failure, void>> call(TrustedContactEntity contact) async {
    return await repository.addContact(contact);
  }
}
