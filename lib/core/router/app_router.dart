import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/post/presentation/pages/dashboard_page.dart';

/// GoRouter configuration with auth guard.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Login route
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // Signup route
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),

      // Dashboard route (protected)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],

    // Auth guard redirect logic
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      // If authenticated and on login/signup page, redirect to dashboard
      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/dashboard';
      }

      // No redirect needed
      return null;
    },

    // Refresh listenable to rebuild routes when auth state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );
}

/// Helper class to convert Stream to Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
