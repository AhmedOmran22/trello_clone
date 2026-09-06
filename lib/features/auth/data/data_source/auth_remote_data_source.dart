import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> loginWithGoogle();

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}
