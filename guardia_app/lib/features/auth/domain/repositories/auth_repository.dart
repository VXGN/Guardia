import 'package:guardia_app/features/auth/domain/entities/user_entity.dart';

/// Auth repository interface for the domain layer.
abstract class AuthRepository {
  /// Sign in with email and password.
  Future<UserEntity> loginWithEmail(String email, String password);

  /// Create a new account with email and password, and set fullName.
  Future<UserEntity> registerWithEmail(String email, String password, {String? fullName});

  /// Sign in with Google.
  Future<UserEntity> loginWithGoogle();

  /// Sign out the current user.
  Future<void> logout();

  /// Stream of authentication state changes.
  Stream<UserEntity?> authState();
}
