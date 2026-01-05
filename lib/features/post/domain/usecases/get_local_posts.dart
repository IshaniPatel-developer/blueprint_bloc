import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for getting local posts.
class GetLocalPosts implements UseCase<List<Post>, NoParams> {
  final PostRepository repository;

  GetLocalPosts(this.repository);

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) async {
    return await repository.getLocalPosts();
  }
}
