// Custom exception classes for error handling.

/// Thrown when a server request fails.
class ServerException implements Exception {
  const ServerException({this.message = 'Server error occurred', this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when local cache operations fail.
class CacheException implements Exception {
  const CacheException({this.message = 'Cache error occurred'});

  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when network is unavailable.
class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Thrown when authentication fails.
class AuthException implements Exception {
  const AuthException({this.message = 'Authentication failed'});

  final String message;

  @override
  String toString() => 'AuthException(message: $message)';
}

/// Thrown when location services fail.
class LocationException implements Exception {
  const LocationException({this.message = 'Location service error'});

  final String message;

  @override
  String toString() => 'LocationException(message: $message)';
}
