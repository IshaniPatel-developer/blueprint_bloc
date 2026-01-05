import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user.
/// This is a domain model, independent of any data source.
class User extends Equatable {
  final String uid;
  final String email;

  const User({required this.uid, required this.email});

  @override
  List<Object> get props => [uid, email];
}
