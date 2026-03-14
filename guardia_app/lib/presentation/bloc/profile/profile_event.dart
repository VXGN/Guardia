import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {

  const UpdateProfileRequested({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.isAnonymousMode,
  });
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final bool? isAnonymousMode;

  @override
  List<Object?> get props => [fullName, email, phoneNumber, isAnonymousMode];
}
