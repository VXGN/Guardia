class ServerException implements Exception {
  ServerException([this.message]);
  final String? message;
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}
