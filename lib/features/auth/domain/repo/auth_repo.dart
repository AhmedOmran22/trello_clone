import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> loginWithGoogle();

  Future<Result<void>> logout();

  Future<Result<UserEntity>> getCurrentUser();
}
