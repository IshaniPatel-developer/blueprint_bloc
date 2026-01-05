import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract contract for remote authentication operations.
abstract class AuthRemoteDataSource {
  /// Login with email and password using Firebase.
  Future<UserModel> login({required String email, required String password});

  /// Sign up with email and password using Firebase.
  Future<UserModel> signup({required String email, required String password});

  /// Logout current user from Firebase.
  Future<void> logout();

  /// Get currently authenticated user from Firebase.
  Future<UserModel?> getCurrentUser();
}

/// Implementation of AuthRemoteDataSource using Firebase Authentication.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in with email and password
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Extract user from credential
      final user = credential.user;
      if (user == null) {
        throw AuthException('Login failed: No user returned');
      }

      // Convert to UserModel
      return UserModel(uid: user.uid, email: user.email ?? email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to create new user with email and password
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Extract user from credential
      final user = credential.user;
      if (user == null) {
        throw AuthException('Signup failed: No user returned');
      }

      // Convert to UserModel
      return UserModel(uid: user.uid, email: user.email ?? email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      return UserModel(uid: user.uid, email: user.email ?? '');
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  /// Convert Firebase auth error codes to user-friendly messages.
  String _getFirebaseErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
