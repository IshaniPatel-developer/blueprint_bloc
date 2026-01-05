import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';

/// Dashboard page - Stateless for better performance and maintainability.
/// All state is managed by PostBloc.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.postsTitle),
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              tooltip: AppStrings.logout,
            ),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Navigate to login if logged out
            if (state is AuthUnauthenticated) {
              context.go('/login');
            }
          },
          child: const _DashboardContent(),
        ),
      ),
    );
  }
}

/// Separate content widget for better code organization.
/// Uses ScrollController via BlocProvider pattern.
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    // Fetch posts on initial load
    context.read<PostBloc>().add(PostFetchRequested());

    return Column(
      children: [
        // Search bar using common widget
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _SearchBar(),
        ),

        // Posts list with pull-to-refresh
        const Expanded(child: _PostsList()),
      ],
    );
  }
}

/// Search bar widget - separate for better organization.
class _SearchBar extends StatelessWidget {
  _SearchBar();

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SearchTextField(
      controller: _searchController,
      hintText: AppStrings.searchHint,
      onChanged: (query) {
        context.read<PostBloc>().add(PostSearchRequested(query));
      },
      onClear: () {
        _searchController.clear();
        context.read<PostBloc>().add(PostSearchRequested(''));
      },
    );
  }
}

/// Posts list widget with scroll pagination and pull-to-refresh.
class _PostsList extends StatelessWidget {
  const _PostsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PostError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              context.read<PostBloc>().add(PostFetchRequested());
            },
          );
        }

        if (state is PostsLoaded) {
          if (state.posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(PostFetchRequested());
                // Wait for the state to update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text(AppStrings.noPostsFound)),
                  ),
                ],
              ),
            );
          }

          return _PostsListView(state: state);
        }

        return const Center(child: Text(AppStrings.welcomeMessage));
      },
    );
  }
}

/// Error view widget - reusable component.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

/// Posts ListView with pagination handling and pull-to-refresh.
class _PostsListView extends StatelessWidget {
  final PostsLoaded state;

  const _PostsListView({required this.state});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    // Add scroll listener for pagination
    scrollController.addListener(() {
      final threshold =
          scrollController.position.maxScrollExtent *
          AppConstants.scrollThresholdForPagination;

      if (scrollController.position.pixels >= threshold) {
        // Load more when threshold reached
        if (state.hasMore) {
          context.read<PostBloc>().add(PostLoadNextPage());
        }
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh
        context.read<PostBloc>().add(PostFetchRequested());
        // Wait for the state to update
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: state.posts.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom if there are more posts
          if (index == state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = state.posts[index];
          return _PostCard(
            id: post.id ?? 0,
            title: post.title,
            body: post.body,
            userId: post.userId,
          );
        },
      ),
    );
  }
}

/// Post card widget - reusable component.
class _PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final String userId;

  const _PostCard({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('$id')),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          body,
          maxLines: AppConstants.maxPostBodyLines,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${AppStrings.userPrefix} $userId',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }
}
