import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

/// Event to subscribe to the authentication status stream.
class AuthStatusSubscriptionRequested extends AuthEvent {}

/// Event when the user attempts to log in with email and password.
class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object> get props => [email, password];
}

/// Event when the user attempts to register with email and password.
class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object> get props => [email, password];
}

/// Event when the user attempts to log in with Google.
class AuthGoogleLoginRequested extends AuthEvent {}

/// Event when the user attempts to log out.
class AuthLogoutRequested extends AuthEvent {}
