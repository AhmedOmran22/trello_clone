import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> loginWithGoogle();

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}