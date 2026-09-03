import '../../../../core/utils/result.dart';
import '../repo/auth_repo.dart';

class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Result<void>> call() {
    return repository.logout();
  }
}
