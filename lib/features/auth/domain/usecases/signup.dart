import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user signup.
class Signup implements UseCase<User, SignupParams> {
  final AuthRepository repository;

  Signup(this.repository);

  @override
  Future<Either<Failure, User>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters required for signup use case.
class SignupParams extends Equatable {
  final String email;
  final String password;

  const SignupParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
