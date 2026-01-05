import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository.
/// Converts data layer exceptions to domain layer failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote datasource to login
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      // Convert auth exception to auth failure
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Handle unexpected errors
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote datasource to signup
      final user = await remoteDataSource.signup(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      // Convert auth exception to auth failure
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Handle unexpected errors
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call remote datasource to logout
      await remoteDataSource.logout();
      return const Right(null);
    } on AuthException catch (e) {
      // Convert auth exception to auth failure
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Handle unexpected errors
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Call remote datasource to get current user
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      // Convert auth exception to auth failure
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Handle unexpected errors
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
