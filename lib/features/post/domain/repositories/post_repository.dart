import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';

/// Abstract repository contract for post operations.
abstract class PostRepository {
  /// Get all posts from API.
  Future<Either<Failure, List<Post>>> getPosts();

  /// Create a new post.
  /// If online: saves to API and then local storage (marked as synced)
  /// If offline: saves to local storage (marked as pending)
  Future<Either<Failure, void>> createPost(Post post);

  /// Sync all pending posts to the server.
  /// Called when internet connection is restored.
  Future<Either<Failure, void>> syncPendingPosts();

  /// Get all posts from local storage.
  Future<Either<Failure, List<Post>>> getLocalPosts();
}
