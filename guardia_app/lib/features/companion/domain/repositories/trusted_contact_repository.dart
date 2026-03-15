import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';

abstract class TrustedContactRepository {
  Future<Either<Failure, List<TrustedContactEntity>>> getContacts();
  Future<Either<Failure, void>> addContact(TrustedContactEntity contact);
  Future<Either<Failure, void>> updateContact(TrustedContactEntity contact);
  Future<Either<Failure, void>> deleteContact(String id);
}
