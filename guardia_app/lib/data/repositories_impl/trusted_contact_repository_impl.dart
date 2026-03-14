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
      final response = await apiClient.get(Endpoints.trustedContacts);
      final dynamic responseData = response.data;
      final contacts = (responseData['data'] as List)
          .map((e) => TrustedContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(contacts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load contacts'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrustedContact>> addTrustedContact({
    required String contactName,
    required String contactPhone,
    String? contactEmail,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.trustedContacts,
        data: {
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
        },
      );

      final dynamic responseData = response.data;
      final contact = TrustedContactModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(contact);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to add contact'));
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
    bool? isActive,
  }) async {
    try {
      final response = await apiClient.put(
        '${Endpoints.trustedContacts}/$id',
        data: {
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
          'is_active': isActive,
        },
      );

      final dynamic responseData = response.data;
      final contact = TrustedContactModel.fromJson(responseData['data'] as Map<String, dynamic>);
      return Right(contact);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update contact'));
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
      return Left(ServerFailure(e.message ?? 'Failed to delete contact'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
