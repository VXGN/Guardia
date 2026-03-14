import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class TrustedContactRepositoryImpl implements TrustedContactRepository {
  TrustedContactRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  // Persistent in-memory list for demo purposes
  static final List<TrustedContact> _mockContacts = [
    TrustedContact(
      id: '1',
      userId: 'user-1',
      contactName: 'Bapa (Emergency)',
      contactPhone: '+62 812-3456-7890',
      contactEmail: 'bapa@example.com',
      relationship: 'Father',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    TrustedContact(
      id: '2',
      userId: 'user-1',
      contactName: 'Mama',
      contactPhone: '+62 811-9876-5432',
      contactEmail: 'mama@example.com',
      relationship: 'Mother',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

  @override
  Future<Either<Failure, List<TrustedContact>>> getTrustedContacts() async {
    // Return a copy of the list to simulate network delay and immutability
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(List.from(_mockContacts));
  }

  @override
  Future<Either<Failure, TrustedContact>> addTrustedContact({
    required String contactName,
    required String contactPhone,
    String? contactEmail,
    String? relationship,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newContact = TrustedContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user-1',
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      relationship: relationship,
      isActive: true,
      createdAt: DateTime.now(),
    );
    _mockContacts.add(newContact);
    return Right(newContact);
  }

  @override
  Future<Either<Failure, TrustedContact>> updateTrustedContact({
    required String id,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? relationship,
    bool? isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockContacts.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = _mockContacts[index];
      final updated = TrustedContact(
        id: old.id,
        userId: old.userId,
        contactName: contactName ?? old.contactName,
        contactPhone: contactPhone ?? old.contactPhone,
        contactEmail: contactEmail ?? old.contactEmail,
        relationship: relationship ?? old.relationship,
        isActive: isActive ?? old.isActive,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _mockContacts[index] = updated;
      return Right(updated);
    }
    return Left(ServerFailure('Contact not found'));
  }

  @override
  Future<Either<Failure, void>> deleteTrustedContact(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockContacts.removeWhere((e) => e.id == id);
    return const Right(null);
  }
}
