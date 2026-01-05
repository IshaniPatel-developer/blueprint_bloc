import 'package:hive/hive.dart';
import '../../domain/entities/post.dart';

part 'post_model.g.dart';

/// Post model for data layer with JSON and Hive serialization.
/// Extends domain entity and adds data transformation.
@HiveType(typeId: 0)
class PostModel extends Post {
  @HiveField(0)
  @override
  final int? id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String body;

  @HiveField(3)
  @override
  final String userId;

  @HiveField(4)
  final String syncStatusString; // Store as string for Hive

  const PostModel({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.syncStatusString = 'synced',
  }) : super(
         id: id,
         title: title,
         body: body,
         userId: userId,
         syncStatus: SyncStatus.synced, // Default, will be overridden
       );

  /// Get sync status from string.
  @override
  SyncStatus get syncStatus {
    switch (syncStatusString) {
      case 'pending':
        return SyncStatus.pending;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.synced;
    }
  }

  /// Create PostModel from JSON (API response).
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId']?.toString() ?? '1',
      syncStatusString: 'synced',
    );
  }

  /// Convert PostModel to JSON (API request).
  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'userId': userId};
  }

  /// Create PostModel from domain entity.
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      title: post.title,
      body: post.body,
      userId: post.userId,
      syncStatusString: _syncStatusToString(post.syncStatus),
    );
  }

  /// Convert sync status enum to string.
  static String _syncStatusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.failed:
        return 'failed';
      case SyncStatus.synced:
        return 'synced';
    }
  }

  /// Copy with method for creating modified copies.
  PostModel copyWithModel({
    int? id,
    String? title,
    String? body,
    String? userId,
    String? syncStatusString,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      syncStatusString: syncStatusString ?? this.syncStatusString,
    );
  }
}
