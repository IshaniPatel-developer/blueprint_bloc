/// API configuration for managing base URLs and settings.
class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _stagingBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _prodBaseUrl = 'https://jsonplaceholder.typicode.com';

  // Current environment (can be changed based on build flavor)
  static const Environment environment = Environment.dev;

  /// Get base URL based on current environment.
  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
    }
  }

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API endpoints
  static const String postsEndpoint = '/posts';
  static const String usersEndpoint = '/users';
  static const String commentsEndpoint = '/comments';

  // Default headers
  static Map<String, dynamic> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}

/// Environment enum for different deployment environments.
enum Environment { dev, staging, prod }
