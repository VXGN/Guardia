import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/auth/get_current_user.dart';
import 'package:guardia_app/domain/usecases/auth/login.dart';
import 'package:guardia_app/domain/usecases/auth/logout.dart';
import 'package:guardia_app/domain/usecases/auth/register.dart';
import 'package:guardia_app/presentation/bloc/auth/auth_event.dart';
import 'package:guardia_app/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }
  final Login loginUser;
  final Register registerUser;
  final Logout logoutUser;
  final GetCurrentUser getCurrentUser;

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(
      identifier: event.identifier,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUser(
      fullName: event.fullName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUser();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}
