import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:guardia_app/core/errors/exceptions.dart';
import 'package:guardia_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:guardia_app/features/auth/domain/entities/user_entity.dart';
import 'package:guardia_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] integrating with Firebase.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }

  Exception _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Email is not registered.');
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException('Incorrect email or password.');
      case 'email-already-in-use':
        return AuthException('This email is already in use by another account.');
      case 'weak-password':
        return AuthException('Password is too weak. Minimum 6 characters.');
      case 'invalid-email':
        return AuthException('Invalid email format.');
      default:
        return AuthException(e.message ?? 'An authentication error occurred.');
    }
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    try {
      final credential = await _dataSource.loginWithEmail(email, password);
      final user = _mapFirebaseUser(credential.user);
      if (user == null) throw AuthException('Failed to load user profile.');
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw ServerException('A server error occurred.');
    }
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password) async {
    try {
      final credential = await _dataSource.registerWithEmail(email, password);
      final user = _mapFirebaseUser(credential.user);
      if (user == null) throw AuthException('Failed to load user profile.');
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw ServerException('A server error occurred.');
    }
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    try {
      final credential = await _dataSource.signInWithGoogle();
      final user = _mapFirebaseUser(credential.user);
      if (user == null) throw AuthException('Failed to load user profile.');
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } on PlatformException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In error: ${e.code}');
    } catch (e) {
      throw ServerException('A server error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Stream<UserEntity?> authState() {
    return _dataSource.authStateChanges().map(_mapFirebaseUser);
  }
}
