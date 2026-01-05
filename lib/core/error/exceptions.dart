/// Base class for exceptions in the data layer.
/// These are converted to Failures in the repository layer.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

/// Exception thrown when cache operations fail.
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

/// Exception thrown when network is unavailable.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

/// Exception thrown during auth operations.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
