import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/features/companion/data/datasources/trusted_contact_local_data_source.dart';
import 'package:guardia_app/features/companion/data/models/trusted_contact_model.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart';

class TrustedContactRepositoryImpl implements TrustedContactRepository {
  final TrustedContactLocalDataSource localDataSource;

  TrustedContactRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TrustedContactEntity>>> getContacts() async {
    try {
      final contacts = await localDataSource.getContacts();
      
      // Migration: Ensure all contacts have unique IDs
      bool hasUpdates = false;
      for (int i = 0; i < contacts.length; i++) {
        if (contacts[i].id.isEmpty) {
          final newId = 'local_migrated_${i}_${DateTime.now().millisecondsSinceEpoch}';
          contacts[i] = TrustedContactModel.fromEntity(contacts[i].copyWith(id: newId));
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await localDataSource.saveContacts(contacts);
      }
      
      return Right(contacts.cast<TrustedContactEntity>());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addContact(TrustedContactEntity contact) async {
    try {
      final contacts = await localDataSource.getContacts();
      // Generate ID if missing (common for local/mock data)
      final contactWithId = contact.id.isEmpty 
          ? contact.copyWith(id: 'local_${DateTime.now().millisecondsSinceEpoch}')
          : contact;
      final model = TrustedContactModel.fromEntity(contactWithId);
      contacts.add(model);
      await localDataSource.saveContacts(contacts);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateContact(TrustedContactEntity contact) async {
    try {
      final contacts = await localDataSource.getContacts();
      final index = contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        contacts[index] = TrustedContactModel.fromEntity(contact);
        await localDataSource.saveContacts(contacts);
        return const Right(null);
      }
      return const Left(CacheFailure('Contact not found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact(String id) async {
    try {
      final contacts = await localDataSource.getContacts();
      contacts.removeWhere((c) => c.id == id);
      await localDataSource.saveContacts(contacts);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
