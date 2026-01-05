import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

/// Abstract contract for local post storage.
abstract class PostLocalDataSource {
  /// Save a post to local storage.
  Future<void> savePost(PostModel post);

  /// Get all posts with pending sync status.
  Future<List<PostModel>> getPendingPosts();

  /// Get all posts from local storage.
  Future<List<PostModel>> getAllPosts();

  /// Mark a post as synced (update sync status).
  Future<void> markAsSynced(PostModel post, int serverId);

  /// Delete a post from local storage.
  Future<void> deletePost(PostModel post);
}

/// Implementation using Hive for local storage.
class PostLocalDataSourceImpl implements PostLocalDataSource {
  static const String postsBoxName = 'posts';

  /// Get the Hive box for posts.
  Future<Box<PostModel>> _getBox() async {
    if (!Hive.isBoxOpen(postsBoxName)) {
      return await Hive.openBox<PostModel>(postsBoxName);
    }
    return Hive.box<PostModel>(postsBoxName);
  }

  @override
  Future<void> savePost(PostModel post) async {
    try {
      final box = await _getBox();

      // Use timestamp as key for pending posts (no server ID yet)
      final key =
          post.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(key, post);
    } catch (e) {
      throw CacheException('Failed to save post: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPendingPosts() async {
    try {
      final box = await _getBox();

      // Filter posts with pending sync status
      final allPosts = box.values.toList();
      return allPosts
          .where((post) => post.syncStatusString == 'pending')
          .toList();
    } catch (e) {
      throw CacheException('Failed to get pending posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final box = await _getBox();
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get all posts: ${e.toString()}');
    }
  }

  @override
  Future<void> markAsSynced(PostModel post, int serverId) async {
    try {
      final box = await _getBox();

      // Find the post by matching title and body (since pending posts use timestamp keys)
      final key = box.keys.firstWhere((k) {
        final p = box.get(k);
        return p?.title == post.title && p?.body == post.body;
      }, orElse: () => null);

      if (key != null) {
        // Update with server ID and synced status
        final updatedPost = post.copyWithModel(
          id: serverId,
          syncStatusString: 'synced',
        );

        // Delete old entry and add new one with server ID as key
        await box.delete(key);
        await box.put(serverId.toString(), updatedPost);
      }
    } catch (e) {
      throw CacheException('Failed to mark as synced: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(PostModel post) async {
    try {
      final box = await _getBox();

      // Find and delete the post
      final key = box.keys.firstWhere((k) {
        final p = box.get(k);
        return p?.title == post.title && p?.body == post.body;
      }, orElse: () => null);

      if (key != null) {
        await box.delete(key);
      }
    } catch (e) {
      throw CacheException('Failed to delete post: ${e.toString()}');
    }
  }
}
