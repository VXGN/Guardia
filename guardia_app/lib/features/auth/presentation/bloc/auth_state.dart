import 'package:equatable/equatable.dart';
import 'package:guardia_app/features/auth/domain/entities/user_entity.dart';

/// Possible statuses for authentication.
enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

/// State object representing the current authentication state.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.message,
  });

  /// Current authentication status.
  final AuthStatus status;

  /// Current authenticated user (if any).
  final UserEntity? user;

  /// Error or informational message.
  final String? message;

  /// Returns a copy of the current state with updated fields.
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? message,
  }) {
    // Note: message is explicitly passed so it can be cleared out if not provided
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
