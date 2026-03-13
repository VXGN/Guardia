import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;

  const LoginSubmitted(this.identifier, this.password);

  @override
  List<Object?> get props => [identifier, password];
}

class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

class LogoutRequested extends AuthEvent {}
