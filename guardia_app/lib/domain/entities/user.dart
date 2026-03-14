import 'package:equatable/equatable.dart';

class User extends Equatable {

  const User({
    required this.id,
    required this.role, required this.isAnonymousMode, required this.isVerified, required this.createdAt, this.fullName,
    this.email,
    this.phoneNumber,
    this.fcmToken,
    this.updatedAt,
    this.deletedAt,
  });
  final String id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String role; // user, admin, partner
  final bool isAnonymousMode;
  final bool isVerified;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        role,
        isAnonymousMode,
        isVerified,
        fcmToken,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
