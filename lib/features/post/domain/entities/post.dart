import 'package:equatable/equatable.dart';

/// Post entity representing a user post.
/// Independent of data sources.
class Post extends Equatable {
  final int? id; // Nullable because new posts don't have an ID yet
  final String title;
  final String body;
  final String userId;
  final SyncStatus syncStatus;

  const Post({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.syncStatus = SyncStatus.synced,
  });

  @override
  List<Object?> get props => [id, title, body, userId, syncStatus];

  /// Copy with method for creating modified copies of Post.
  Post copyWith({
    int? id,
    String? title,
    String? body,
    String? userId,
    SyncStatus? syncStatus,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// Enum representing the sync status of a post.
enum SyncStatus {
  pending, // Not yet synced to server
  synced, // Successfully synced to server
  failed, // Sync attempt failed
}
