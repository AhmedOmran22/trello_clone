import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Result<UserEntity>> loginWithGoogle() async {
    try {
      final model = await datasource.loginWithGoogle();
      return Result.success(model.toEntity());
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await datasource.logout();
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    try {
      final model = await datasource.getCurrentUser();
      return Result.success(model.toEntity());
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }
}
