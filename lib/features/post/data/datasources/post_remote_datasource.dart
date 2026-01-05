import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

/// Abstract contract for remote post operations.
abstract class PostRemoteDataSource {
  /// Get all posts from JSONPlaceholder API.
  Future<List<PostModel>> getPosts();

  /// Post to JSONPlaceholder API.
  Future<PostModel> createPost(PostModel post);
}

/// Implementation using Dio for HTTP requests.
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      // Send GET request to JSONPlaceholder API
      final response = await dio.get('$baseUrl/posts');

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse response list
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch posts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('Request timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      // Send POST request to JSONPlaceholder API
      final response = await dio.post('$baseUrl/posts', data: post.toJson());

      // Check if request was successful
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse response and return PostModel
        return PostModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to create post: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('Request timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
