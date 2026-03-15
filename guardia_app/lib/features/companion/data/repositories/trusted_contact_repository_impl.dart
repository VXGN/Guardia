import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/domain/repositories/trusted_contact_repository.dart';

class TrustedContactRepositoryImpl implements TrustedContactRepository {
  final ApiClient apiClient;

  TrustedContactRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<TrustedContactEntity>>> getContacts() async {
    try {
      final response = await apiClient.get(Endpoints.trustedContacts);
      final body = response.data;
      final dynamic rawData = body is Map<String, dynamic> ? body['data'] : null;
      final List<dynamic> items = rawData is List ? rawData : <dynamic>[];

      final contacts = items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => TrustedContactEntity(
              id: (item['id'] ?? '').toString(),
              userId: (item['user_id'] ?? '').toString(),
              contactName: (item['contact_name'] ?? '').toString(),
              contactPhone: (item['contact_phone'] ?? '').toString(),
              contactEmail: item['contact_email']?.toString(),
              relationship: item['relationship']?.toString(),
              isActive: (item['is_active'] as bool?) ?? true,
              createdAt: DateTime.tryParse((item['created_at'] ?? '').toString()) ?? DateTime.now(),
              updatedAt: DateTime.tryParse((item['updated_at'] ?? '').toString()),
            ),
          )
          .toList();

      return Right(contacts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addContact(TrustedContactEntity contact) async {
    try {
      await apiClient.post(
        Endpoints.trustedContacts,
        data: {
          'contact_name': contact.contactName,
          'contact_phone': contact.contactPhone,
          if (contact.contactEmail != null && contact.contactEmail!.isNotEmpty)
            'contact_email': contact.contactEmail,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateContact(TrustedContactEntity contact) async {
    try {
      await apiClient.put(
        '${Endpoints.trustedContacts}/${contact.id}',
        data: {
          'contact_name': contact.contactName,
          'contact_phone': contact.contactPhone,
          'contact_email': contact.contactEmail,
          'is_active': contact.isActive,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact(String id) async {
    try {
      await apiClient.delete('${Endpoints.trustedContacts}/$id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
