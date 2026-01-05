import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

/// Use case for syncing pending posts to server.
class SyncPosts implements UseCase<void, NoParams> {
  final PostRepository repository;

  SyncPosts(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncPendingPosts();
  }
}
