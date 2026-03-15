import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart';

class GetTrustedContacts {
  final TrustedContactRepository repository;

  GetTrustedContacts(this.repository);

  Future<Either<Failure, List<TrustedContactEntity>>> call() async {
    return await repository.getContacts();
  }
}
