import 'package:equatable/equatable.dart';

/// Base class for all post events.
abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

/// Event to create a new post.
class PostCreateRequested extends PostEvent {
  final String title;
  final String body;
  final String userId;

  const PostCreateRequested({
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  List<Object> get props => [title, body, userId];
}

/// Event to sync pending posts.
class PostSyncRequested extends PostEvent {}

/// Event to fetch posts from API.
class PostFetchRequested extends PostEvent {}

/// Event to search posts locally.
class PostSearchRequested extends PostEvent {
  final String query;

  const PostSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

/// Event to load next page of posts.
class PostLoadNextPage extends PostEvent {}
