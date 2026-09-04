import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';
import '../repo/auth_repo.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  const LoginWithGoogleUseCase(this.repository);

  Future<Result<UserEntity>> call() {
    return repository.loginWithGoogle();
  }
}
