import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_datasource.dart';
import '../datasources/post_remote_datasource.dart';
import '../models/post_model.dart';

/// Implementation of PostRepository with offline-first logic.
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      // Check if device has internet connection
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // ONLINE: Fetch from API
        try {
          final posts = await remoteDataSource.getPosts();

          // Save to local cache for offline access
          for (final post in posts) {
            await localDataSource.savePost(post);
          }

          return Right(posts);
        } on ServerException catch (e) {
          // API failed, try to get from local cache
          return Left(ServerFailure(e.message));
        } on NetworkException catch (e) {
          // Network error, try to get from local cache
          return Left(NetworkFailure(e.message));
        }
      } else {
        // OFFLINE: Get from local cache
        return await getLocalPosts();
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createPost(Post post) async {
    try {
      final postModel = PostModel.fromEntity(post);

      // Check if device has internet connection
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // ONLINE: Try to post to API first
        try {
          final response = await remoteDataSource.createPost(postModel);

          // Save to local storage with synced status and server ID
          final syncedPost = postModel.copyWithModel(
            id: response.id,
            syncStatusString: 'synced',
          );
          await localDataSource.savePost(syncedPost);

          return const Right(null);
        } on ServerException catch (e) {
          // API failed, save locally as pending
          final pendingPost = postModel.copyWithModel(
            syncStatusString: 'pending',
          );
          await localDataSource.savePost(pendingPost);
          return Left(ServerFailure(e.message));
        } on NetworkException catch (e) {
          // Network error, save locally as pending
          final pendingPost = postModel.copyWithModel(
            syncStatusString: 'pending',
          );
          await localDataSource.savePost(pendingPost);
          return Left(NetworkFailure(e.message));
        }
      } else {
        // OFFLINE: Save to local storage with pending status
        final pendingPost = postModel.copyWithModel(
          syncStatusString: 'pending',
        );
        await localDataSource.savePost(pendingPost);
        return const Right(null);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingPosts() async {
    try {
      // Get all pending posts from local storage
      final pendingPosts = await localDataSource.getPendingPosts();

      if (pendingPosts.isEmpty) {
        return const Right(null);
      }

      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      // Sync each pending post
      for (final post in pendingPosts) {
        try {
          // Upload to server
          final response = await remoteDataSource.createPost(post);

          // Mark as synced in local storage
          await localDataSource.markAsSynced(post, response.id!);
        } on ServerException catch (e) {
          // If one fails, continue with others but log the failure
          print('Failed to sync post: ${post.title}, error: ${e.message}');
          continue;
        } on NetworkException catch (e) {
          // If network fails, stop sync process
          return Left(NetworkFailure(e.message));
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Sync error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getLocalPosts() async {
    try {
      final posts = await localDataSource.getAllPosts();
      return Right(posts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get posts: ${e.toString()}'));
    }
  }
}
