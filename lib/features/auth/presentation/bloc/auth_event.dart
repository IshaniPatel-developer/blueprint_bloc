import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event to check if user is already authenticated.
class AuthCheckRequested extends AuthEvent {}

/// Event to trigger login.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event to trigger signup.
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignupRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event to trigger logout.
class AuthLogoutRequested extends AuthEvent {}
