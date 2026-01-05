import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/get_local_posts.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/sync_posts.dart';
import 'post_event.dart';
import 'post_state.dart';

/// BLoC for managing post state.
/// Handles post fetching, pagination, and search.
class PostBloc extends Bloc<PostEvent, PostState> {
  final CreatePost createPostUseCase;
  final SyncPosts syncPostsUseCase;
  final GetLocalPosts getLocalPostsUseCase;
  final GetPosts getPostsUseCase;

  // Store all posts for pagination and search
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  static const int _postsPerPage = 20;
  int _currentPage = 0;

  PostBloc({
    required this.createPostUseCase,
    required this.syncPostsUseCase,
    required this.getLocalPostsUseCase,
    required this.getPostsUseCase,
  }) : super(PostInitial()) {
    // Handle post fetching
    on<PostFetchRequested>(_onFetchRequested);

    // Handle search
    on<PostSearchRequested>(_onSearchRequested);

    // Handle post creation
    on<PostCreateRequested>(_onCreateRequested);

    // Handle sync
    on<PostSyncRequested>(_onSyncRequested);

    // Handle load next page
    on<PostLoadNextPage>(_onLoadNextPage);
  }

  /// Handle fetch posts request.
  Future<void> _onFetchRequested(
    PostFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final result = await getPostsUseCase(NoParams());

    result.fold((failure) => emit(PostError(failure.message)), (posts) {
      _allPosts = posts;
      _filteredPosts = posts;
      _currentPage = 0;

      // Get first page
      final paginatedPosts = _getPaginatedPosts();
      emit(
        PostsLoaded(
          posts: paginatedPosts,
          hasMore: _hasMorePosts(),
          currentPage: _currentPage,
          totalPosts: _allPosts.length,
        ),
      );
    });
  }

  /// Handle search request.
  Future<void> _onSearchRequested(
    PostSearchRequested event,
    Emitter<PostState> emit,
  ) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      // Reset to all posts
      _filteredPosts = _allPosts;
    } else {
      // Filter posts by title or body
      _filteredPosts = _allPosts.where((post) {
        return post.title.toLowerCase().contains(query) ||
            post.body.toLowerCase().contains(query);
      }).toList();
    }

    _currentPage = 0;
    final paginatedPosts = _getPaginatedPosts();

    emit(
      PostsLoaded(
        posts: paginatedPosts,
        hasMore: _hasMorePosts(),
        currentPage: _currentPage,
        totalPosts: _filteredPosts.length,
      ),
    );
  }

  /// Handle post creation.
  Future<void> _onCreateRequested(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final post = Post(
      title: event.title,
      body: event.body,
      userId: event.userId,
      syncStatus: SyncStatus.pending,
    );

    final result = await createPostUseCase(post);

    result.fold((failure) {
      if (failure.message.contains('No internet') ||
          failure.message.contains('network') ||
          failure.message.contains('Network')) {
        emit(
          const PostCreated('Post saved offline. Will sync when connected.'),
        );
      } else {
        emit(PostError(failure.message));
      }
    }, (_) => emit(const PostCreated('Post created successfully!')));

    // Reload posts
    add(PostFetchRequested());
  }

  /// Handle sync request.
  Future<void> _onSyncRequested(
    PostSyncRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostSyncing());

    final result = await syncPostsUseCase(NoParams());

    result.fold(
      (failure) => emit(PostError(failure.message)),
      (_) => emit(const PostSynced('All posts synced successfully!')),
    );

    // Reload posts
    add(PostFetchRequested());
  }

  /// Handle load next page.
  Future<void> _onLoadNextPage(
    PostLoadNextPage event,
    Emitter<PostState> emit,
  ) async {
    if (_hasMorePosts()) {
      _currentPage++;
      final paginatedPosts = _getPaginatedPosts();

      emit(
        PostsLoaded(
          posts: paginatedPosts,
          hasMore: _hasMorePosts(),
          currentPage: _currentPage,
          totalPosts: _filteredPosts.length,
        ),
      );
    }
  }

  /// Get paginated posts for current page.
  List<Post> _getPaginatedPosts() {
    final startIndex = 0;
    final endIndex = (_currentPage + 1) * _postsPerPage;

    if (startIndex >= _filteredPosts.length) {
      return [];
    }

    return _filteredPosts.sublist(
      startIndex,
      endIndex > _filteredPosts.length ? _filteredPosts.length : endIndex,
    );
  }

  /// Check if there are more posts to load.
  bool _hasMorePosts() {
    final loadedCount = (_currentPage + 1) * _postsPerPage;
    return loadedCount < _filteredPosts.length;
  }
}
