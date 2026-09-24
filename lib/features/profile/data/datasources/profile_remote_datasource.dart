import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String fullName});
  Future<String> uploadAvatar({required String userId, required String filePath});
  Future<void> removeAvatar({required String userId});
}
