import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/post_model.dart';

/// Abstract contract for remote post operations.
abstract class PostRemoteDataSource {
  /// Get all posts from JSONPlaceholder API.
  Future<List<PostModel>> getPosts();

  /// Post to JSONPlaceholder API.
  Future<PostModel> createPost(PostModel post);
}

/// Implementation using ApiClient for HTTP requests.
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getPosts() async {
    // Use ApiClient's get method - error handling is done by interceptors
    final response = await apiClient.get(ApiConfig.postsEndpoint);

    // Parse response list
    final List<dynamic> jsonList = response;
    return jsonList.map((json) => PostModel.fromJson(json)).toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    // Use ApiClient's post method - error handling is done by interceptors
    final response = await apiClient.post(
      ApiConfig.postsEndpoint,
      data: post.toJson(),
    );

    // Parse response and return PostModel
    return PostModel.fromJson(response);
  }
}
