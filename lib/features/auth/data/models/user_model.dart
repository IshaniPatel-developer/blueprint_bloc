import '../../domain/entities/user.dart';

/// User model for data layer with JSON serialization.
/// Extends the domain entity to add data transformation capabilities.
class UserModel extends User {
  const UserModel({required super.uid, required super.email});

  /// Create UserModel from JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
    );
  }

  /// Convert UserModel to JSON.
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email};
  }

  /// Create UserModel from domain entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(uid: user.uid, email: user.email);
  }
}
