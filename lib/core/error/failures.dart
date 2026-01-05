import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Using Equatable for value comparison of failure instances.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when server returns an error or unexpected response.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure when local cache/database operations fail.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure when network connection is unavailable.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure during authentication operations (login, signup, etc).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
