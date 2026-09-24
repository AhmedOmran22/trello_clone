import '../../../../core/utils/result.dart';
import '../../../auth/domain/entity/user_entity.dart';

abstract class ProfileRepo {
  Future<Result<UserEntity>> getProfile();
  Future<Result<UserEntity>> updateProfile({required String fullName});
  Future<Result<String>> uploadAvatar({required String userId, required String filePath});
  Future<Result<void>> removeAvatar({required String userId});
}
