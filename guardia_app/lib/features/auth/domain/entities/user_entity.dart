import 'package:equatable/equatable.dart';

/// User entity model for the domain layer.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  @override
  List<Object?> get props => [id, email, name];
}
