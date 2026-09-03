import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';
import '../repo/auth_repo.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<Result<UserEntity>> call() {
    return repository.getCurrentUser();
  }
}