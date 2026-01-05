import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';
import 'api_config.dart';

/// Interceptor for logging HTTP requests and responses.
/// Only active in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '╔══════════════════════════════════════════════════════════════════════',
        name: 'API REQUEST',
      );
      dev.log('║ ${options.method} ${options.uri}', name: 'API REQUEST');
      dev.log('║ Headers: ${options.headers}', name: 'API REQUEST');
      if (options.data != null) {
        dev.log('║ Body: ${options.data}', name: 'API REQUEST');
      }
      dev.log(
        '╚══════════════════════════════════════════════════════════════════════',
        name: 'API REQUEST',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '╔══════════════════════════════════════════════════════════════════════',
        name: 'API RESPONSE',
      );
      dev.log(
        '║ ${response.requestOptions.method} ${response.requestOptions.uri}',
        name: 'API RESPONSE',
      );
      dev.log('║ Status Code: ${response.statusCode}', name: 'API RESPONSE');
      dev.log('║ Data: ${response.data}', name: 'API RESPONSE');
      dev.log(
        '╚══════════════════════════════════════════════════════════════════════',
        name: 'API RESPONSE',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '╔══════════════════════════════════════════════════════════════════════',
        name: 'API ERROR',
      );
      dev.log(
        '║ ${err.requestOptions.method} ${err.requestOptions.uri}',
        name: 'API ERROR',
      );
      dev.log('║ Error Type: ${err.type}', name: 'API ERROR');
      dev.log('║ Error Message: ${err.message}', name: 'API ERROR');
      if (err.response != null) {
        dev.log(
          '║ Status Code: ${err.response?.statusCode}',
          name: 'API ERROR',
        );
        dev.log('║ Response: ${err.response?.data}', name: 'API ERROR');
      }
      dev.log(
        '╚══════════════════════════════════════════════════════════════════════',
        name: 'API ERROR',
      );
    }
    super.onError(err, handler);
  }
}

/// Interceptor for adding authentication tokens to requests.
class AuthInterceptor extends Interceptor {
  /// Get auth token from secure storage.
  /// TODO: Implement actual token retrieval from secure storage.
  Future<String?> _getAuthToken() async {
    // This will be implemented when auth tokens are stored
    // For now, return null
    return null;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get auth token
    final token = await _getAuthToken();

    // Add token to headers if available
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}

/// Interceptor for handling errors and converting to custom exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to custom exceptions
    final exception = _handleError(err);

    // Reject with custom exception
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ),
    );
  }

  /// Convert Dio errors to custom exceptions.
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);

      case DioExceptionType.cancel:
        return ServerException('Request was cancelled');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return ServerException('Certificate verification failed');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkException('No internet connection');
        }
        return ServerException('Unexpected error occurred: ${error.message}');
    }
  }

  /// Handle HTTP status codes.
  Exception _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ServerException('Bad request');
      case 401:
        return AuthException('Unauthorized. Please login again.');
      case 403:
        return AuthException('Forbidden. You do not have permission.');
      case 404:
        return ServerException('Resource not found');
      case 500:
      case 502:
      case 503:
        return ServerException('Server error. Please try again later.');
      default:
        return ServerException('Request failed with status: $statusCode');
    }
  }
}

/// Interceptor for retrying failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = ApiConfig.maxRetries,
    this.retryDelay = ApiConfig.retryDelay,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network errors or timeouts
    final shouldRetry =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    // Get retry count from request options
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (retryCount >= maxRetries) {
      if (kDebugMode) {
        dev.log(
          'Max retries ($maxRetries) reached for ${err.requestOptions.uri}',
          name: 'RETRY',
        );
      }
      return super.onError(err, handler);
    }

    // Calculate delay with exponential backoff
    final delay = retryDelay * (retryCount + 1);

    if (kDebugMode) {
      dev.log(
        'Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s: ${err.requestOptions.uri}',
        name: 'RETRY',
      );
    }

    // Wait before retrying
    await Future.delayed(delay);

    // Increment retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Retry the request
    try {
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return super.onError(e, handler);
    }
  }
}
