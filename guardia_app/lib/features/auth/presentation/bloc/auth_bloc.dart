import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthStatusSubscriptionRequested>(_onAuthStatusSubscriptionRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.loginWithGoogle();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.message));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } on ServerException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.message));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: 'Gagal login dengan Google: $e'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthStatusSubscriptionRequested(
    AuthStatusSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach(
      _authRepository.authState(),
      onData: (user) {
        if (user != null) {
          return state.copyWith(status: AuthStatus.authenticated, user: user);
        }
        return state.copyWith(status: AuthStatus.unauthenticated, user: null);
      },
      onError: (_, __) => state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.loginWithEmail(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.message));
      // Revert to unauthenticated on failure
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: 'Gagal login.'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.registerWithEmail(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.message));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: 'Gagal register.'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
  }
}
