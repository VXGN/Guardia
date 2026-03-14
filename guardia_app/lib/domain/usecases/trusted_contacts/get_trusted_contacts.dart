import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class GetTrustedContacts {

  GetTrustedContacts(this.repository);
  final TrustedContactRepository repository;

  Future<Either<Failure, List<TrustedContact>>> call() async {
    return repository.getTrustedContacts();
  }
}
