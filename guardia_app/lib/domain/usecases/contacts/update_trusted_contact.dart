import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class UpdateTrustedContact {
  final TrustedContactRepository repository;

  UpdateTrustedContact(this.repository);

  Future<Either<Failure, TrustedContact>> call({
    required String id,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
  }) async {
    return await repository.updateTrustedContact(
      id: id,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      isActive: isActive,
    );
  }
}
