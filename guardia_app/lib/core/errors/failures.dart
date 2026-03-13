import 'package:equatable/equatable.dart';

/// Base failure class for BLoC error handling.
/// Use these in the domain/BLoC layer instead of exceptions.
abstract class Failure extends Equatable {
  const Failure({this.message = 'An unexpected error occurred'});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-related failures.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server failure'});
}

/// Cache-related failures.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure'});
}

/// Network-related failures.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Authentication-related failures.
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failure'});
}

/// Location-related failures.
class LocationFailure extends Failure {
  const LocationFailure({super.message = 'Location service failure'});
}
