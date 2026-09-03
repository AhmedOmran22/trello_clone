import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';
import '../repo/auth_repo.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.register(email: email, password: password, fullName: fullName);
  }
}
