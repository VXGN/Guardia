import 'package:equatable/equatable.dart';
import 'package:guardia_app/domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final bool? isAnonymousMode;

  const UpdateProfileRequested({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.isAnonymousMode,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, isAnonymousMode];
}
