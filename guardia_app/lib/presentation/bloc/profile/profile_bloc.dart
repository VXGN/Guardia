import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/user/get_profile.dart';
import 'package:guardia_app/domain/usecases/user/update_profile.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_event.dart';
import 'package:guardia_app/presentation/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }
  final GetProfile getProfileUseCase;
  final UpdateProfile updateProfileUseCase;

  Future<void> _onLoadProfileRequested(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await updateProfileUseCase(
      fullName: event.fullName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      isAnonymousMode: event.isAnonymousMode,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}
