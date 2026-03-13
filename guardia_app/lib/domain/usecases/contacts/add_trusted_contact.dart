import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class AddTrustedContact {
  final TrustedContactRepository repository;

  AddTrustedContact(this.repository);

  Future<Either<Failure, TrustedContact>> call({
    required String contactName,
    required String contactPhone,
    String? contactEmail,
  }) async {
    return await repository.addTrustedContact(
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );
  }
}
