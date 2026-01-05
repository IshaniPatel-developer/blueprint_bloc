import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract repository contract for authentication operations.
/// The data layer will implement this interface.
abstract class AuthRepository {
  /// Login with email and password.
  /// Returns Either<Failure, User> - Left for errors, Right for success.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  /// Returns Either<Failure, User> - Left for errors, Right for success.
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
  });

  /// Logout the current user.
  /// Returns Either<Failure, void> - Left for errors, Right for success.
  Future<Either<Failure, void>> logout();

  /// Get currently authenticated user.
  /// Returns Either<Failure, User?> - null if no user is logged in.
  Future<Either<Failure, User?>> getCurrentUser();
}
