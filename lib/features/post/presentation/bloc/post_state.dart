import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

/// Base class for all post states.
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class PostInitial extends PostState {}

/// State when post operation is in progress.
class PostLoading extends PostState {}

/// State when post is successfully created.
class PostCreated extends PostState {
  final String message;

  const PostCreated(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when posts are successfully loaded.
class PostsLoaded extends PostState {
  final List<Post> posts;
  final bool hasMore;
  final int currentPage;
  final int totalPosts;

  const PostsLoaded({
    required this.posts,
    required this.hasMore,
    required this.currentPage,
    required this.totalPosts,
  });

  @override
  List<Object?> get props => [posts, hasMore, currentPage, totalPosts];
}

/// State when sync is in progress.
class PostSyncing extends PostState {}

/// State when sync is successful.
class PostSynced extends PostState {
  final String message;

  const PostSynced(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a post error occurs.
class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
