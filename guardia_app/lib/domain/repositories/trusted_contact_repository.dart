import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';

abstract class TrustedContactRepository {
  Future<Either<Failure, List<TrustedContact>>> getTrustedContacts();

  Future<Either<Failure, TrustedContact>> addTrustedContact({
    required String contactName,
    required String contactPhone,
    String? contactEmail,
  });

  Future<Either<Failure, TrustedContact>> updateTrustedContact({
    required String id,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
  });

  Future<Either<Failure, void>> deleteTrustedContact(String id);
}
