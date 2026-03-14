import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {

  const LoginSubmitted(this.identifier, this.password);
  final String identifier;
  final String password;

  @override
  List<Object?> get props => [identifier, password];
}

class RegisterSubmitted extends AuthEvent {

  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

class LogoutRequested extends AuthEvent {}
