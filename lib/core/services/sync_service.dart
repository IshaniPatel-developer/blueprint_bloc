import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../injection_container.dart';
import '../../features/post/domain/usecases/sync_posts.dart';
import '../usecases/usecase.dart';

/// Service that listens to connectivity changes and auto-syncs posts.
class SyncService {
  final Connectivity _connectivity;
  final SyncPosts _syncPostsUseCase;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  SyncService({
    required Connectivity connectivity,
    required SyncPosts syncPostsUseCase,
  }) : _connectivity = connectivity,
       _syncPostsUseCase = syncPostsUseCase;

  /// Start listening to connectivity changes.
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // Also check initial connectivity
    _checkInitialConnectivity();
  }

  /// Check connectivity on service start.
  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  /// Handle connectivity change events.
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected =
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet);

    // If connection is restored after being offline, trigger sync
    if (isConnected && _wasOffline) {
      print('✅ Internet connection restored. Syncing pending posts...');
      _syncPendingPosts();
    }

    // Update offline status
    _wasOffline = !isConnected;

    if (!isConnected) {
      print('❌ No internet connection. Posts will be saved locally.');
    }
  }

  /// Sync pending posts to server.
  Future<void> _syncPendingPosts() async {
    final result = await _syncPostsUseCase(NoParams());

    result.fold(
      (failure) => print('❌ Sync failed: ${failure.message}'),
      (_) => print('✅ All pending posts synced successfully!'),
    );
  }

  /// Stop listening to connectivity changes.
  void dispose() {
    _subscription?.cancel();
  }
}

/// Initialize and start the sync service.
SyncService initializeSyncService() {
  final service = SyncService(connectivity: sl(), syncPostsUseCase: sl());

  service.startListening();

  return service;
}
