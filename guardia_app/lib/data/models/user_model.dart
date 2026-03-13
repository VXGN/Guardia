import 'package:guardia_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.fullName,
    super.email,
    super.phoneNumber,
    required super.role,
    required super.isAnonymousMode,
    required super.isVerified,
    super.fcmToken,
    required super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
      isAnonymousMode: json['is_anonymous_mode'] as bool,
      isVerified: json['is_verified'] as bool,
      fcmToken: json['fcm_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'is_anonymous_mode': isAnonymousMode,
      'is_verified': isVerified,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
