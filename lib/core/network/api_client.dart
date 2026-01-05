import 'dart:io';
import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// Centralized API client for all HTTP operations.
/// Provides common methods for GET, POST, PUT, PATCH, DELETE, and file uploads.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Perform GET request.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Perform POST request.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Perform PUT request.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Perform PATCH request.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Perform DELETE request.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [data] - Optional request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Upload a single file.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [filePath] - Path to the file to upload
  /// [fileFieldName] - The field name for the file (default: 'file')
  /// [data] - Additional form data to send with the file
  /// [onSendProgress] - Callback for upload progress
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> uploadFile(
    String endpoint,
    String filePath, {
    String fileFieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Create multipart file
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );

      // Create form data
      final formData = FormData.fromMap({fileFieldName: file, ...?data});

      // Upload
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Upload multiple files.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [filePaths] - List of file paths to upload
  /// [fileFieldName] - The field name for the files (default: 'files')
  /// [data] - Additional form data to send with the files
  /// [onSendProgress] - Callback for upload progress
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> uploadFiles(
    String endpoint,
    List<String> filePaths, {
    String fileFieldName = 'files',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Create multipart files
      final files = await Future.wait(
        filePaths.map((path) async {
          return await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          );
        }),
      );

      // Create form data
      final formData = FormData.fromMap({fileFieldName: files, ...?data});

      // Upload
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to upload files: ${e.toString()}');
    }
  }

  /// Upload an image with optional compression.
  ///
  /// [endpoint] - API endpoint (without base URL)
  /// [imagePath] - Path to the image file
  /// [fileFieldName] - The field name for the image (default: 'image')
  /// [data] - Additional form data to send with the image
  /// [onSendProgress] - Callback for upload progress
  ///
  /// Returns the response data.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<dynamic> uploadImage(
    String endpoint,
    String imagePath, {
    String fileFieldName = 'image',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Validate that the file is an image
      final extension = imagePath.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

      if (!validExtensions.contains(extension)) {
        throw ServerException(
          'Invalid image format. Supported formats: ${validExtensions.join(', ')}',
        );
      }

      // Check if file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw ServerException('Image file not found: $imagePath');
      }

      // Upload using uploadFile method
      return await uploadFile(
        endpoint,
        imagePath,
        fileFieldName: fileFieldName,
        data: data,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Failed to upload image: ${e.toString()}');
    }
  }

  /// Download a file.
  ///
  /// [url] - URL to download from
  /// [savePath] - Path where to save the downloaded file
  /// [onReceiveProgress] - Callback for download progress
  ///
  /// Returns the path to the downloaded file.
  /// Throws [ServerException], [NetworkException], or [AuthException].
  Future<String> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
      return savePath;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to download file: ${e.toString()}');
    }
  }

  /// Handle successful response.
  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data;
    } else {
      throw ServerException(
        'Request failed with status: ${response.statusCode}',
      );
    }
  }

  /// Handle DioException and convert to custom exceptions.
  Exception _handleDioException(DioException error) {
    // If error already has a custom exception, return it
    if (error.error is ServerException ||
        error.error is NetworkException ||
        error.error is AuthException) {
      return error.error as Exception;
    }

    // Otherwise, create a generic server exception
    return ServerException('Request failed: ${error.message}');
  }
}
