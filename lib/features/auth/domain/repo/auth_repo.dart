import '../../../../core/utils/result.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<UserEntity>> loginWithGoogle();

  Future<Result<void>> logout();

  Future<Result<UserEntity>> getCurrentUser();
}
