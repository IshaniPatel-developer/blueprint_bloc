import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for creating a post.
class CreatePost implements UseCase<void, Post> {
  final PostRepository repository;

  CreatePost(this.repository);

  @override
  Future<Either<Failure, void>> call(Post params) async {
    return await repository.createPost(params);
  }
}
