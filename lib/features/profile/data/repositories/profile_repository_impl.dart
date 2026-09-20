import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../../domain/repo/profile_repo.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepo {
  final ProfileRemoteDatasource datasource;

  ProfileRepositoryImpl(this.datasource);

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final model = await datasource.getProfile();
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({required String fullName}) async {
    try {
      final model = await datasource.updateProfile(fullName: fullName);
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<String>> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final avatarUrl = await datasource.uploadAvatar(userId: userId, filePath: filePath);
      return Result.success(avatarUrl);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> removeAvatar({required String userId}) async {
    try {
      await datasource.removeAvatar(userId: userId);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }
}
