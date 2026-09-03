import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';
import '../repo/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
