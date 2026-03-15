import 'package:dartz/dartz.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/core/errors/failures.dart';
import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/data/models/trusted_contact_model.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/domain/repositories/trusted_contact_repository.dart';

class TrustedContactRepositoryImpl implements TrustedContactRepository {
  TrustedContactRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<TrustedContact>>> getTrustedContacts() async {
    try {
      // Mock data for testing purposes
      final contacts = [
        TrustedContactModel(
          id: '1',
          userId: 'user123',
          contactName: 'John Doe',
          contactPhone: '+1234567890',
          contactEmail: 'john@example.com',
          relationship: 'Family',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        TrustedContactModel(
          id: '2',
          userId: 'user123',
          contactName: 'Jane Smith',
          contactPhone: '+0987654321',
          contactEmail: 'jane@example.com',
          relationship: 'Friend',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        TrustedContactModel(
          id: '3',
          userId: 'user123',
          contactName: 'Emergency Contact',
          contactPhone: '911',
          relationship: 'Emergency',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        ),
      ];
      return Right(contacts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrustedContact>> addTrustedContact({
    required String contactName,
    required String contactPhone,
    String? contactEmail,
    String? relationship,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.trustedContacts,
        data: {
          'contact_name': contactName,
          'contact_phone': contactPhone,
          if (contactEmail != null) 'contact_email': contactEmail,
        },
      );

      final dynamic responseData = response.data;
      final contact =
          TrustedContactModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(contact);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to add trusted contact'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
    try {
      final payload = <String, dynamic>{
        if (contactName != null) 'contact_name': contactName,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (isActive != null) 'is_active': isActive,
      };

      if (contactEmail != null) {
        payload['contact_email'] = contactEmail;
      }

      final response = await apiClient.put(
        '${Endpoints.trustedContacts}/$id',
        data: payload,
      );

      final dynamic responseData = response.data;
      final contact =
          TrustedContactModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(contact);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update trusted contact'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrustedContact(String id) async {
    try {
      await apiClient.delete('${Endpoints.trustedContacts}/$id');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete trusted contact'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
