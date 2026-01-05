import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base UseCase class that all use cases should extend.
/// Type - The return type wrapped in Either<Failure, Type>
/// Params - The parameters required by the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with given parameters.
  /// Returns Either<Failure, Type> for proper error handling.
  Future<Either<Failure, Type>> call(Params params);
}

/// Used for use cases that don't require parameters.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
